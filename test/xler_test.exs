defmodule XlerTest do
  use ExUnit.Case, async: true

  @fixture Path.join(__DIR__, "/data/example.xlsx")
  @moduletag :tmp_dir

  describe "worksheets/1" do
    test "can read worksheets from xlsx file" do
      assert Xler.worksheets(@fixture) == {:ok, ["Sheet1"]}
    end

    test "file not found", %{tmp_dir: tmp_dir} do
      assert Xler.worksheets(Path.join(tmp_dir, "not_found.xlsx")) == {
               :error,
               "Xlsx error: I/O error: No such file or directory (os error 2)"
             }
    end

    test "file is not a sheet", %{tmp_dir: tmp_dir} do
      file_path = Path.join(tmp_dir, "invalid.xlsx")
      File.write!(file_path, "invalid")

      assert Xler.worksheets(file_path) == {
               :error,
               "Xlsx error: Zip error: invalid Zip archive: Invalid zip header"
             }
    end
  end

  describe "parse/3" do
    test "parses a sheet and data types" do
      assert {:ok, data} =
               Xler.parse(@fixture, "Sheet1",
                 format: %{
                   skip_rows: [0],
                   columns: [
                     %{column: 0, data_type: :integer},
                     %{column: 1, data_type: :float},
                     %{column: 3, data_type: :boolean},
                     %{column: 4, data_type: :date},
                     %{column: 5, data_type: :time},
                     %{column: 6, data_type: :datetime}
                   ]
                 }
               )

      assert data == [
               ["Int", "Float", "String", "Bool", "Date", "Time", "DateTime", "Empty"],
               [
                 10,
                 20.12,
                 "text",
                 true,
                 ~D[2022-01-30],
                 ~T[09:51:00],
                 ~N[2022-01-30 09:51:00],
                 nil
               ]
             ]
    end

    test "returns raw value when fails to format data type" do
      assert {:ok, data} =
               Xler.parse(@fixture, "Sheet1",
                 format: %{
                   skip_rows: [],
                   columns: [
                     %{column: 0, data_type: :integer},
                     %{column: 1, data_type: :float},
                     %{column: 3, data_type: :bool},
                     %{column: 4, data_type: :date},
                     %{column: 5, data_type: :time},
                     %{column: 6, data_type: :datetime}
                   ]
                 }
               )

      assert List.first(data) == [
               "Int",
               "Float",
               "String",
               "Bool",
               "Date",
               "Time",
               "DateTime",
               "Empty"
             ]
    end

    def custom_formatter(value) do
      "#{value}customformatter"
    end

    test "support custom formatters" do
      assert {:ok, data} =
               Xler.parse(@fixture, "Sheet1",
                 format: %{
                   skip_rows: [0],
                   columns: [
                     %{column: 0, data_type: {__MODULE__, :custom_formatter}}
                   ]
                 }
               )

      assert List.last(data) == [
               "10customformatter",
               "20.12",
               "text",
               "1",
               "44591",
               "0.410416666666667",
               "44591.4104166667",
               nil
             ]
    end

    test "worksheet not found" do
      assert Xler.parse(@fixture, "Invalid") == {:error, "Couldnt find the worksheet"}
    end

    test "file not found", %{tmp_dir: tmp_dir} do
      assert Xler.parse(Path.join(tmp_dir, "not_found.xlsx"), "Sheet1") == {
               :error,
               "Xlsx error: I/O error: No such file or directory (os error 2)"
             }
    end

    test "file is not a sheet", %{tmp_dir: tmp_dir} do
      file_path = Path.join(tmp_dir, "invalid.xlsx")
      File.write!(file_path, "invalid")

      assert Xler.parse(file_path, "Sheet1") == {
               :error,
               "Xlsx error: Zip error: invalid Zip archive: Invalid zip header"
             }
    end
  end
end
