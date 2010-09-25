# Wonderful monkey patch required cause we use bit field for booleans - yeah hibernate
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def quote_with_bit_type(value, column = nil)
        if column && column.sql_type == "bit(1)"
          tf = value.kind_of? Bool ? value : value.to_s.include?('1')
          "b'#{tf ? '1': '0'}'"
        else
          quote_without_bit_type(value, column)
        end 
      end 
      alias_method_chain :quote, :bit_type

      class MysqlColumn < Column
      private
        def simplified_type_with_bit_type(field_type)
          return :boolean if MysqlAdapter.emulate_booleans && field_type.downcase.index("bit(1)")
          simplified_type_without_bit_type(field_type)
        end 
        alias_method_chain :simplified_type, :bit_type

        def extract_limit_with_bit_type(sql_type)
          if sql_type == 'bit(1)' then 1 else
            extract_limit_without_bit_type(sql_type)
          end 
        end 
        alias_method_chain :extract_limit, :bit_type
      end 
    end 
  end 
end
