defmodule Sportyweb.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.InternalEvent

  @doc """
  Returns a clubs list of transactions.

  ## Examples

      iex> list_transactions(1)
      [%Transaction{}, ...]

  """
  def list_transactions(club_id) do
    club = Organization.get_club!(club_id, [:transactions])
    club.transactions
  end

  @doc """
  Returns a clubs list of transactions. Preloads associations.

  ## Examples

      iex> list_transactions(1, [:contract])
      [%Transaction{}, ...]

  """
  def list_transactions(club_id, preloads) do
    Repo.preload(list_transactions(club_id), preloads)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Gets a single transaction. Preloads associations.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123, [:club])
      %Transaction{}

      iex> get_transaction!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id, preloads) do
    Transaction
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  # TODO: Add docs

  def forecast_transactions(type, [%Contract{} | _] = contracts, %Date{} = start_date, %Date{} = end_date) do
    get_transactions(type, contracts, start_date, end_date)
  end

  def forecast_transactions(:fee, _, %Date{} = start_date, %Date{} = end_date) do
    {[], Money.new(:EUR, 0)}
  end

  def create_transactions(type, [%Contract{} | _] = contracts, %Date{} = start_date, %Date{} = end_date) do
    get_transactions(type, contracts, start_date, end_date)
  end

  defp get_transactions(type, [%Contract{} | _] = contracts, %Date{} = start_date, %Date{} = end_date) do
    # Iterate over all days from start to end. It's possible that start_date == end_date.
    date_range = Date.range(start_date, end_date)

    # Calculating the occurrence_dates for each fee or subsidy and for the entire range of dates from start to end
    # only once via this function call and passing the result as a parameter to all subsequent functions, is much
    # faster than doing this calculation for every fee or subsidy and every day over and over again!
    occurrence_dates = get_occurrence_dates(type, contracts, start_date, end_date)

    transactions =
      date_range
      |> Enum.map(fn date ->
        get_transactions(type, contracts, occurrence_dates, date)
      end)
      |> List.flatten()

    transactions_amount_sum = Enum.reduce(transactions, Money.new(:EUR, 0), fn transaction, acc ->
      Money.add!(acc, transaction.amount)
    end)

    {transactions, transactions_amount_sum}
  end

  defp get_occurrence_dates(:fee, [%Contract{} | _] = contracts, %Date{} = start_date, %Date{} = end_date) do
    # Get a list of all fees, some of them might be used by multiple contracts.
    fees = Enum.map(contracts, fn contract -> contract.fee end)
    # Filter out possible duplicates.
    unique_fees = Enum.uniq_by(fees, fn fee -> fee.id end)
    # Create a map that has fee ids as keys and the list of occurrence_dates for each of those fees as value.
    unique_fees
    |> Enum.map(fn fee ->
      internal_event = Enum.at(fee.internal_events, 0) # There must be an internal event, let it fail otherwise!
      occurrence_dates = get_occurrence_dates(internal_event, start_date, end_date)
      {fee.id, occurrence_dates}
    end)
    |> Enum.into(%{})
  end

  defp get_transactions(:fee, [%Contract{} | _] = contracts, %{} = fees_occurrence_dates, %Date{} = date) do
    contracts
    |> Enum.filter(fn contract ->
      if Contract.is_in_use?(contract, date) && Fee.is_in_use?(contract.fee, date) do
        Enum.any?(fees_occurrence_dates[contract.fee.id], fn occurrence_date ->
          Date.compare(date, occurrence_date) == :eq
        end)
      end
    end)
    |> Enum.map(fn contract ->
      # "Default" transaction for the base amount of the fee.
      transactions = [
        %{
          id: nil,
          contract_id: contract.id,
          contract: contract,
          name: "Gebühr: #{contract.fee.name} - Grundbetrag",
          amount: contract.fee.amount,
          creation_date: date
        }
      ]

      # Possible additional transaction for the one-time amount of the fee.
      if is_nil(contract.first_billing_date) do
        transaction = [
          %{
            id: nil,
            contract_id: contract.id,
            contract: contract,
            name: "Gebühr: #{contract.fee.name} - Einmalzahlung",
            amount: contract.fee.amount_one_time,
            creation_date: date
          }
        ]

        # TODO: contract.first_billing_date setzen bei erster echter Abrechnung.

        transactions ++ transaction
      else
        transactions
      end
    end)
  end

  defp get_occurrence_dates(:subsidy, [%Contract{} | _] = contracts, %Date{} = start_date, %Date{} = end_date) do
    # Get a list of all subsidies, some of them might be nil or used by multiple contracts (via fees).
    subsidies =
      contracts
      |> Enum.filter(fn contract -> contract.fee.subsidy end) # Filter out nil.
      |> Enum.map(fn contract -> contract.fee.subsidy end)
    # Filter out possible duplicates.
    unique_subsidies = Enum.uniq_by(subsidies, fn subsidy -> subsidy.id end)
    # Create a map that has subsidy ids as keys and the list of occurrence_dates for each of those subsidies as value.
    unique_subsidies
    |> Enum.map(fn subsidy ->
      internal_event = Enum.at(subsidy.internal_events, 0) # There must be an internal event, let it fail otherwise!
      occurrence_dates = get_occurrence_dates(internal_event, start_date, end_date)
      {subsidy.id, occurrence_dates}
    end)
    |> Enum.into(%{})
  end

  defp get_transactions(:subsidy, [%Contract{} | _] = contracts, %{} = subsidies_occurrence_dates, %Date{} = date) do
    contracts
    |> Enum.filter(fn contract ->
      fee = contract.fee
      subsidy = fee.subsidy
      if subsidy && Contract.is_in_use?(contract, date) && Fee.is_in_use?(fee, date) && Subsidy.is_in_use?(subsidy, date) do
        Enum.any?(subsidies_occurrence_dates[contract.fee.subsidy.id], fn occurrence_date ->
          Date.compare(date, occurrence_date) == :eq
        end)
      end
    end)
    |> Enum.map(fn contract ->
      %{
        id: nil,
        contract_id: contract.id,
        contract: contract,
        name: "Zuschuss: #{contract.fee.subsidy.name}",
        amount: contract.fee.subsidy.amount,
        creation_date: date
      }
    end)
  end

  defp get_occurrence_dates(%InternalEvent{} = internal_event, %Date{} = start_date, %Date{} = end_date) do
    # "Cocktail", the date recurrence library in use doesn't natively support a yearly frequency.
    # Therefore, the interval might have to be converted from year to month via a multiplication by 12.
    interval = case internal_event.frequency do
      "month" -> internal_event.interval
      "year"  -> internal_event.interval * 12
    end

    # The commission_date of the interal_event is the starting point for all subsequent recurring dates.
    # It has to be converted to NaiveDateTime because "Cocktail" requires it.
    time = ~T[00:00:00.000000]
    {:ok, commission_datetime} = NaiveDateTime.new(internal_event.commission_date, time)

    # To keep things fast, the generation/calculation of recurring dates should be limited to a minimum.
    # This can be achieved by setting the until_datetime based on different criteria/conditions.
    until_datetime = if internal_event.is_recurring do
      if internal_event.archive_date do
        day_before_archive_date = Date.add(internal_event.archive_date, -1)
        {:ok, until_datetime} = NaiveDateTime.new(day_before_archive_date, time)
        until_datetime
      else
        {:ok, end_datetime} = NaiveDateTime.new(end_date, time)
        end_datetime
      end
    else
      commission_datetime
    end

    # Calculate the occurrences of the recurring dates with "Cocktail".
    schedule = Cocktail.Schedule.new(commission_datetime)
    schedule = Cocktail.Schedule.add_recurrence_rule(schedule, :monthly, interval: interval, until: until_datetime)
    occurrences_stream = Cocktail.Schedule.occurrences(schedule)

    # Convert the occurrences to Date and filter them, so they only include dates in the range from start_date to end_date.
    # Convert the stream to a list at the end, to make it easier to work with.
    occurrences_stream
    |> Stream.map(&NaiveDateTime.to_date/1)
    |> Stream.filter(fn date -> Date.compare(date, start_date) != :lt && Date.compare(date, end_date) != :gt end)
    |> Enum.to_list()
  end
end