         VARIABLE output1 clob

           begin 
           dbms_utility.expand_sql_text 
           ( input_sql_text => 'select * from aijibril.t201600003a', 
           output_sql_text => :output1 ); 
           end; /  

           print outout1
