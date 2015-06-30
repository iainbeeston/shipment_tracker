module Sections
  class TableSection
    def initialize(table_element, icon_translations: {})
      @table_element = table_element
      @icon_translations = icon_translations
    end

    def items
      @items ||= begin
        headers      = table_element.all('thead th').map(&:text)
        row_elements = table_element.all('tbody tr')

        row_elements.map { |row_element|
          row_element.all('td').map(&method(:cell_text))
        }.map { |cells_text|
          Hash[headers.zip(cells_text)]
        }
      end
    end

    private

    attr_reader :table_element, :icon_translations

    def cell_text(cell_element)
      icon_element = cell_element.first('.glyphicon')
      if icon_element
        icon_translation_for(icon_element)
      else
        cell_element.text
      end
    end

    def icon_translation_for(icon_element)
      icon_element['class'].split(' ').map {|klass|
        icon_translations[klass]
      }.compact.first
    end
  end
end
