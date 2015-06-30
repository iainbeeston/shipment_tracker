module Sections
  class TableSection
    def initialize(table_element)
      @table_element = table_element
    end

    def items
      @items ||= begin
        headers      = table_element.all('thead th').map(&:text)
        row_elements = table_element.all('tbody tr')

        row_elements.map { |row_element|
          row_element.all('td').map(&:text)
        }.map { |cell_text|
          Hash[headers.zip(cell_text)]
        }
      end
    end

    private

    attr_reader :table_element
  end
end
