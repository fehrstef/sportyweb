defmodule SportywebWeb.DownloadController do
  use SportywebWeb, :controller

  alias Sportyweb.Membership
  alias Sportyweb.Membership.Member


  def members(conn, _params) do
    export_list(conn)
  end

  def export_list(conn) do
    members = Membership.list_members("d55550b7-5f09-4848-96d4-e57c2ac9c767")

    # export with elixlsx
    #    sheet = Elixlsx.Sheet.with_name("Sheet 1")
    #            |> Elixlsx.Sheet.set_cell("A1", "Hello", bold: true)
    #    Enum.with_index(members, fn m, i ->
    #      sheet
    #      |> Elixlsx.Sheet.set_cell("A" + (i + 1), m.last_name)
    #    end)
    #    Elixlsx.Workbook.append_sheet(%Elixlsx.Workbook{}, sheet ) |> Elixlsx.write_to("/tmp/elixlsx.xlsx")

    # export with exceed
    headings = ["Nachname", "Vorname", "Geschlecht", "Status", "Geburtsdatum"];
    rows = Enum.map(members, fn m -> [m.last_name, m.first_name, m.gender, m.state, m.birthday] end)
    worksheet = Exceed.Worksheet.new("Sheet Name", headings, rows)

    workbook =
      Exceed.Workbook.new("Creator Name")
      |> Exceed.Workbook.add_worksheet(worksheet)

    workbook
    |> Exceed.stream!()
    |> Stream.into(File.stream!("/tmp/exceed.xlsx"))
    |> Stream.run()

    send_download(
      conn,
      {:binary, Base.decode64!(workbook)},
      filename: "export.xlsx"
    )
  end


end
