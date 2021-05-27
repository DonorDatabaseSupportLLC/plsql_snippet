CREATE OR REPLACE PACKAGE namer_abdi
AUTHID current_user
  IS
/*****************************************************************
PACKAGE:        NAMER

DESCRIPTION:    Query Team names package for all name functions

TABLES:         q_individual     SELECT

PACKAGE
DEPENDANCIES:   NONE.

SPECIAL
REQUIREMENTS:   INDEXS, SEQUENCES, ETC....

INPUT/OUTPUT
FILE NAMES:     E.G. USER_ID||_FILE_NAME

PROGRAMMER:     Jim Fairweather

DATE:           08-JAN-2003

+++++++++++
AUDIT TRAIL
+++++++++++

DATE            NAME                    DESCRIPTION
-----------     ----------------------- ----------------------------


*****************************************************************/

--CONSTANTS
--VARIABLES
--CURSORS
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES


--***********************************************************
--***********************************************************
  FUNCTION indv_addressee
-- returns RE individual_addressee, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
  FUNCTION indv_salutation
-- returns RE individual_salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
  FUNCTION couple_addressee
-- returns RE couple_addressee, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
  FUNCTION couple_salutation
-- returns RE couple_salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
  FUNCTION re_addressee
-- returns RE addressee, if exists, else namer.label().
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
  FUNCTION re_salutation
-- returns RE salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type;
--***********************************************************
--***********************************************************
END NAMER_ABDI;
