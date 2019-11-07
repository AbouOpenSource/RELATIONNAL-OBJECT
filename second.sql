CREATE TYPE veh_typ AS OBJECT 
        (
            no_immat VARCHAR2 (8), 
            date_immat DATE,
            type_v VARCHAR2(7),
            marque VARCHAR2(15)
        ) ;
/ 
CREATE TYPE contrat_typ AS OBJECT 
        (
            no_contrat VARCHAR2 (5), 
            montant NUMBER, 
            ref_client VARCHAR2(50)
        ) ;
/

CREATE TYPE intervention_typ AS OBJECT 
        (
            cont REF  contrat_typ, 
            date_fin_cont DATE, 
            ville VARCHAR2(20), 
            distance NUMBER
        ) ;
        
/ 
CREATE TYPE interventions_typ AS TABLE OF intervention_typ 
/

CREATE or replace TYPE employe_typ AS OBJECT 
        (
            numero VARCHAR2(5), 
            nom VARCHAR2(15), 
            prenom VARCHAR2(15), 
            veh REF  veh_typ, 
            indem_resid NUMBER, 
            lieux_interventions interventions_typ
            MAP MEMBER FUNCTION get_idno RETURN NUMBER, 
            MEMBER FUNCTION show RETURN VARCHAR2 

        ) 
/
CREATE TABLE contrats OF contrat_typ (PRIMARY KEY (no_contrat)) 
/

CREATE TABLE vehicules OF veh_typ (PRIMARY KEY (no_immat)) 
/ 
CREATE TABLE employes OF employe_typ (PRIMARY KEY (numero)) NESTED TABLE lieux_interventions STORE AS tab_interv 
/

Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V1','10-10-2010','Berline','TOYOTA');
Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V2','10-10-2010','Berline','MERCEDES');
Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V3','10-10-2010','COUPE','RENAULT');
Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V4','10-10-2010','Berline','HONDA');
Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V5','10-10-2010','4*4','BMW');
Insert INTO vehicules(no_immat , date_immat , type_v , marque) values('V7','10-10-2010','Berline','TOYOTA');
select * from vehicules;

Insert INTO contrats(no_contrat , montant , ref_client) values('C1',10000,'E1');
Insert INTO contrats(no_contrat , montant , ref_client) values('C2',100000,'E2');
Insert INTO contrats(no_contrat , montant , ref_client) values('C3',1000000,'E3');
Insert INTO contrats(no_contrat , montant , ref_client) values('C4',10000000,'E4');

select * from contrats;

Insert INTO employes(numero , nom , prenom, veh, indem_resid, lieux_interventions ) values('E1','SANOU','Abou Dramane',null,1335,interventions_typ());
Insert INTO employes(numero , nom , prenom, veh, indem_resid, lieux_interventions ) values('E2','SANOU','Abou Dramane',null,1000,interventions_typ());
Insert INTO employes(numero , nom , prenom, veh, indem_resid, lieux_interventions ) values('E4','SANOU','Abou Dramane',null,200,interventions_typ());
Insert INTO employes(numero , nom , prenom, veh, indem_resid, lieux_interventions ) values('E3','SANOU','Abou Dramane',null,479,interventions_typ());


select * from employes;
select ref(v) from vehicules v where v.no_immat='V1';

INSERT INTO THE ( SELECT Emp.lieux_interventions FROM employes Emp WHERE Emp.Numero = 'E1') VALUES ( null, '15-07-2004' , 'Ouagadougou', 0);

INSERT INTO THE ( SELECT Emp.lieux_interventions FROM employes Emp WHERE Emp.Numero = 'E1') VALUES ( null, '15-07-2005' , 'Bobo-Dioulasso' , 0);

INSERT INTO THE ( SELECT Emp.lieux_interventions FROM employes Emp WHERE Emp.Numero = 'E1') VALUES ( null, '15-07-2006' , 'Ouhaigouya',0);



/*Insert les references */
Insert INTO employes select 'E5', 'SOW', 'ZAp', ref(v),305, interventions_typ() from vehicules v where v.no_immat='V1'; 
Insert INTO employes select 'E6', 'SOMA', 'ZAKARIA', ref(v),405, interventions_typ() from vehicules v where v.no_immat='V2'; 
Insert INTO employes select 'E7', 'KANE', 'MAH', ref(v),505, interventions_typ() from vehicules v where v.no_immat='V3'; 


INSERT INTO employes 
                SELECT 'E9', 'Ouattara' , 'Oumar', REF(v) ,2800, 
                                interventions_typ( 
                                                        intervention_typ(null , '05/04/2005' , 'Louga' , 200), 
                                                        intervention_typ(null , '05/08/2004' , 'Tamba' , 600)
                                                ) 
                            FROM vehicules v WHERE v.no_immat='V5';
                            

/*Inserer les ref avec au niveau des tables imbriquées*/

INSERT INTO THE (SELECT e.lieux_interventions FROM employes e  WHERE e.numero='E6') 
                        SELECT REF(c),'15/11/2004' , 'Bobo-Dsso' , 250 FROM contrats c WHERE c.no_contrat='C2';
                        

Update employes emp set 
                emp.indem_resid = emp.indem_resid*1.05
                where exits 
                        (select * from 
                                THE (SELECT E.lieux_interventions from employes E where E.numero = emp.numero) Li 
                                WHERE Li.distance > 200
                        );
                                        

UPDATE THE 
            (SELECT emp.lieux_interventions FROM  Employes  emp WHERE  emp.numero="E1" )  lieux SET lieux.date_fin_cont='12-12-2020' WHERE lieux.ville like 'Bobo Dioulasso' ;



SELECT DEREF (t.veh) FROM employes t;


































/*Les pour afficher*/


/*
SET SERVEROUTPUT ON;
Declare 
    emp employe_typ;
    cursor list_employes is Select * from employes ;
    Begin 
        open list_employes;
            loop
                fetch list_employes into emp;
                     DBMS_OUTPUT.PUT_LINE(emp.nom ||' '|| emp.prenom  ||' '|| emp.indem_resid );
                    exit when list_employes%NOTFOUND;
            end loop;
        close list_employes;
    END;
