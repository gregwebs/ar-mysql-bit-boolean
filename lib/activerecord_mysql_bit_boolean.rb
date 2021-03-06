if Rails.version =~ /^3/
  ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.add "b'1'"
  ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.add "\001"

  ActiveRecord::ConnectionAdapters::MysqlColumn.class_eval do
    QUOTED_TRUE, QUOTED_FALSE = "b'1'", "b'0'"

  private
    def simplified_type_with_bit_type(field_type)
      return :boolean if ActiveRecord::ConnectionAdapters::MysqlAdapter.emulate_booleans && field_type.downcase.index("bit(1)")
      simplified_type_without_bit_type(field_type)
    end 
    alias_method_chain :simplified_type, :bit_type

    # probably not important
    def extract_limit_with_bit_type(sql_type)
      if sql_type == 'bit(1)' then 1 else
        extract_limit_without_bit_type(sql_type)
      end 
    end 
    alias_method_chain :extract_limit, :bit_type
  end 

  ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
    # unecessary on MySQL 5.1 - it will convert 0 and 1 to binary
    def quote_with_bit_type(value, column = nil)
      if column && column.sql_type == "bit(1)"
        "b'#{ [QUOTED_TRUE, "\001", true].include?(value) ? '1': '0'}'"
      else
        quote_without_bit_type(value, column)
      end 
    end 
    alias_method_chain :quote, :bit_type
  end 
else
  ActiveRecord::ConnectionAdapters::MysqlColumn.class_eval do
    TRUE_VALUES.add "b'1'"
    TRUE_VALUES.add "\001"

  private
    def simplified_type_with_bit_type(field_type)
      return :boolean if MysqlAdapter.emulate_booleans && field_type.downcase.index("bit(1)")
      simplified_type_without_bit_type(field_type)
    end 
    alias_method_chain :simplified_type, :bit_type

    # probably not important
    def extract_limit_with_bit_type(sql_type)
      if sql_type == 'bit(1)' then 1 else
        extract_limit_without_bit_type(sql_type)
      end 
    end 
    alias_method_chain :extract_limit, :bit_type
  end 

  ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
    # unecessary on MySQL 5.1 - it will convert 0 and 1 to binary
    def quote_with_bit_type(value, column = nil)
      if column && column.sql_type == "bit(1)"
        "b'#{ MysqlColumn::TRUE_VALUES.include?(value) ? '1': '0'}'"
      else
        quote_without_bit_type(value, column)
      end 
    end 
    alias_method_chain :quote, :bit_type
  end 
end
