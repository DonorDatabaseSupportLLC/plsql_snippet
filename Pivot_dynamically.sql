CREATE OR REPLACE procedure dynamic_pivot_pro(p_cursor in out sys_refcursor)
as
    sql_query varchar2(1000) := 'select dept_total ';

    begin
        for x in (select distinct code_dept from t201603498d order by 1)
        loop
            sql_query := sql_query ||
                ' , min(case when code_dept = '''||x.code_dept||''' then 1 else null end) as dept_'||x.code_dept;

                dbms_output.put_line(sql_query);
        end loop;

        sql_query := sql_query || ' from t201603498d group by code_dept order by code_dept';
        dbms_output.put_line(sql_query);

        open p_cursor for sql_query;
    end;
/

; 

variable x sys_refcursor ;
exec dynamic_pivot_pro(:x)
print x
