create or replace type adresse_type as object 
(
    numerorue VARCHAR(5),
    nomrue VARCHAR(30),
    nomville VARCHAR(30)
)
/

CREATE OR REPLACE TYPE departement_type as object 
(
    numero NUMBER,
    nom VARCHAR(50),
    lieu VARCHAR(30)
)
/

CREATE OR REPLACE TYPE employe_type as object
(
    matricule VARCHAR(5),
    nom VARCHAR(30),
    adresse adresse_type,
    salaire NUMBER,
    superieur ref employe_type,
    departement ref departement_type
)
/

CREATE TABLE departements of departement_type (
   numero PRIMARY KEY 
) 
/

CREATE TABLE employes of employe_type (
   matricule PRIMARY KEY 
) 
/

drop type departement_type force;



/*Alimenter en données les tables crées*/

Insert into departements(numero, nom, lieu) values (1,'Nounan','Hauts Bassins');
Insert into departements(numero, nom, lieu) values (2,'Leguema','Hauts Bassins');

Insert into employes 
                    select 'E1' , 'SANOU' ,adresse_type('R479','Séguédé SAnou','Bobo-Dioulasso'), 10000, null, ref(dept) 
                                        from departements dept 
                                                    where dept.numero=1;

Insert into employes select 'E2' ,'KANE', adresse_type('R355','Avenue de la vie','Bobo-Dioulasso'), 1000, ref(emp), ref(dept) from departements dept, employes emp  where dept.numero=1 and emp.matricule='E1';

Insert into employes select 'E3' ,'Diaby', adresse_type('R255','Marchand dor','Bobo-Dioulasso'), 100, ref(emp), ref(dept) from departements dept, employes emp where dept.numero=1 and emp.matricule='E2';
select * from departements;

select * from employes;

select matricule, nom, adresse , deref(superieur).nom, deref(departement).lieu from employes; 



select matricule, nom, adresse , deref(superieur).nom, deref(departement).lieu from employes where deref(departement).numero=1;


Update employes emp set 
                emp.departement= (select ref(dept) from departements dept where dept.numero=2)
                    where emp.matricule='E3';

Update employes emp set 
                emp.superieur= (select ref(emp) from employes e where e.matricule='E1')
                    where emp.matricule='E3';




CREATE TYPE liste AS VARRAY(4) OF VARCHAR(80);
/

CREATE OR REPLACE TYPE personne_type as object 
(   numero NUMBER,
    nom varchar(30),
    mesprenoms liste
)
/

CREATE TABLE personnes of personne_type (
   numero PRIMARY KEY 
) 
/
describe personnes;


Insert into personnes 
                    values
                        (
                            1,
                            'Traore',
                            liste('Go' ,'Issa')
                        );
Insert into personnes values(2,'Coulibaly',liste('Cheick' ,'Yacouba','Rachid'));
Insert into personnes values(3,'Bombiri',liste('Barnabé' ,'Oziyas','Issouf','Josué'));
/


select nom , (select * from TABLE(pers.mesprenoms) where rownum=1 ) from personnes pers where pers.numero=3;

SET SERVEROUTPUT ON;
Declare 
    emp personne_type;
    cursor liste_personne is select nom, mesprenoms from personnes ;
    Begin 
        open liste_personne;
            loop
                fetch liste_personne into emp;
                     DBMS_OUTPUT.PUT_LINE(emp.nom ||' '|| emp.mesprenoms. NEXT(1)) ;
                exit when liste_personne%NOTFOUND;
            end loop;
        close liste_personne;
    END;
/

/*heritage */

CREATE or replace TYPE travailleur_type UNDER personne_type 
(   salaire number
        );

CREATE TABLE travailleurs of travailleur_type (
   matricule PRIMARY KEY 
) 
/
