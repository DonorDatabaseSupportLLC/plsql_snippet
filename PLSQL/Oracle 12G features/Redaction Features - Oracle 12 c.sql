/* 
	Question:  What does the Oracle data redaction feature do in Oracle 12c?
	Answer:  The data redaction feature, first introduced in Oracle 12c, allows for the masking of sensitive data from the end-user layer. Prior to Oracle 12c, you had 	 to create views to "hide" sensitive column (pay rate, social_security_number, credit card numbers, etc.), but in 12c and beyond you can use the data redaction          feature.

       Any online user has experienced data redaction, which amounts to the replacement of sensitive data with asterisk list or other descriptive "masked" data.

       In traditional data redaction, the data is never visible to the end-user and it is hidden via the use of views or via virtual private databases (VPD).  Unlike views        and VPD's, the data remaining unchanged at the database level and it is only "hidden from viewing".

       Examples of data redaction include:

*/

             Password:    **********
   Credit card number:    0000-0000-0000-0000-3632 

BEGIN
   DBMS_REDACT.ADD_POLICY(
     object_schema        => 'scott',
     object_name          => 'emp',
     column_name          => 'social_security_number',
     policy_name          => 'emp_ssn',
     function_type        => DBMS_REDACT.PARTIAL,
     function_parameters  => '*,1,5',
     expression           => '1=1');
END;