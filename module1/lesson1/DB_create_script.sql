/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     10/19/2018 6:44:15 AM                        */
/*==============================================================*/
use [data_camp];
go
create schema data;
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CLIENT') and o.name = 'FK_CLIENT_REFERENCE_EDUCATIO')
alter table DATA.CLIENT
   drop constraint FK_CLIENT_REFERENCE_EDUCATIO
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CLIENT') and o.name = 'FK_CLIENT_REFERENCE_MARITAL_')
alter table DATA.CLIENT
   drop constraint FK_CLIENT_REFERENCE_MARITAL_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CLIENT_ADDRESS') and o.name = 'FK_CLIENT_A_REFERENCE_CLIENT')
alter table DATA.CLIENT_ADDRESS
   drop constraint FK_CLIENT_A_REFERENCE_CLIENT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CREDIT') and o.name = 'FK_CREDIT_REFERENCE_CLIENT')
alter table DATA.CREDIT
   drop constraint FK_CREDIT_REFERENCE_CLIENT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CREDIT') and o.name = 'FK_CREDIT_REFERENCE_STATUS')
alter table DATA.CREDIT
   drop constraint FK_CREDIT_REFERENCE_STATUS
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.REPAYMENT_SCHEDULE') and o.name = 'FK_REPAYMEN_REFERENCE_CREDIT')
alter table DATA.REPAYMENT_SCHEDULE
   drop constraint FK_REPAYMEN_REFERENCE_CREDIT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DATA.CREDIT') and o.name = 'FK_CREDIT_REFERENCE_LOAN_TYP')
alter table DATA.CREDIT
   drop constraint FK_CREDIT_REFERENCE_LOAN_TYP
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.CLIENT')
            and   type = 'U')
   drop table DATA.CLIENT
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.CLIENT_ADDRESS')
            and   type = 'U')
   drop table DATA.CLIENT_ADDRESS
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.CREDIT')
            and   type = 'U')
   drop table DATA.CREDIT
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.EDUCATION')
            and   type = 'U')
   drop table DATA.EDUCATION
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.MARITAL_STATUS')
            and   type = 'U')
   drop table DATA.MARITAL_STATUS
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.REPAYMENT_SCHEDULE')
            and   type = 'U')
   drop table DATA.REPAYMENT_SCHEDULE
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.STATUS')
            and   type = 'U')
   drop table DATA.STATUS
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DATA.LOAN_TYPE')
            and   type = 'U')
   drop table DATA.LOAN_TYPE
go

/*==============================================================*/
/* Table: CLIENT                                                */
/*==============================================================*/
create table DATA.CLIENT (
   CLIENT_ID            int                  identity,
   CLIENT_NAME          varchar(20)          not null,
   CLIENT_SURNAME       varchar(20)          not null,
   CLIENT_LASTNAME      varchar(20)          not null,
   CLIENT_EGN           varchar(10)          not null,
   CLIENT_GENDER        char(1)              null
      constraint CKC_CLIENT_GENDER_CLIENT check (CLIENT_GENDER is null or (CLIENT_GENDER in ('F','M'))),
   CLIENT_BIRTHDATE     date                 not null,
   CLIENT_IDCARD_NO     varchar(10)          not null,
   CLIENT_IDCARD_ISSUED date                 not null,
   CLIENT_IDCARD_VALIDTO date                 not null,
   CLIENT_IDCARD_ISSUER varchar(10)          not null,
   EDU_CODE             char(1)              null,
   CLIENT_INCOME        numeric(10,2)        null,
   MSTATUS_CODE         char(1)              null,
   MODIFIED_ON          date                 null,
   MODIFIED_BY          varchar(50)          null,
   constraint PK_CLIENT primary key (CLIENT_ID)
)
go

/*==============================================================*/
/* Table: DATA.CLIENT_ADDRESS                                        */
/*==============================================================*/
create table DATA.CLIENT_ADDRESS (
   ADDRES_ID            int                  identity,
   CLIENT_ID            int                  not null,
   ADDRESS_PCODE        char(5)              null,
   ADDRESS_TYPE         char(1)              null
      constraint CKC_ADDRESS_TYPE_CLIENT_A check (ADDRESS_TYPE is null or (ADDRESS_TYPE in ('P','C','K'))),
   ADDRESS_TOWN         varchar(100)         null,
   ADDRESS_TEXT         varchar(100)         null,
   constraint PK_CLIENT_ADDRESS primary key (ADDRES_ID)
)
go

/*==============================================================*/
/* Table: DATA.CREDIT                                                */
/*==============================================================*/
create table DATA.CREDIT (
   CREDIT_NO            numeric              identity,
   CLIENT_ID            int                  not null,
   LOAN_TYPE_ID         int                  not null,
   CREDIT_SIGNED        char(1)              null
      constraint CKC_CREDIT_SIGNED_CREDIT check (CREDIT_SIGNED is null or (CREDIT_SIGNED in ('Y','N'))),
   CREDIT_BEGIN_DATE    date                 not null,
   CREDIT_END_DATE      date                 not null,
   CREDIT_SUM           numeric(10,2)        not null,
   CREDIT_INTEREST_PRC  numeric(5,2)         not null,
   CREDIT_ALLSUM        numeric(10,2)        not null,
   CREDIT_GPR           numeric(5,2)         not null,
   STATUS_CODE          char(1)              not null,
   CREDIT_FIRST_MATURITY date                not null,
   CREDIT_ISNTALLMENTS_CNT int               not null,
   CREDIT_INSTALLMENT   numeric(10,2)        not null,
   MODIFIED_ON          date                 null,
   MODIFIED_BY          varchar(50)          null,
   constraint PK_CREDIT primary key (CREDIT_NO)
)
go

/*==============================================================*/
/* Table: DATA.EDUCATION                                             */
/*==============================================================*/
create table DATA.EDUCATION (
   EDU_CODE             char(1)              not null,
   EDU_NAME             varchar(100)         null,
   constraint PK_EDUCATION primary key (EDU_CODE)
)
go

/*==============================================================*/
/* Table: DATA.MARITAL_STATUS                                        */
/*==============================================================*/
create table DATA.MARITAL_STATUS (
   MSTATUS_CODE         char(1)              not null,
   MSTATUS_NAME         varchar(100)         null,
   constraint PK_MARITAL_STATUS primary key (MSTATUS_CODE)
)
go

/*==============================================================*/
/* Table: DATA.LOAN_TYPE                                             */
/*==============================================================*/
create table DATA.LOAN_TYPE (
   LOAN_TYPE_ID         int                  not null,
   LAON_TYPE_NAME       varchar(100)         not null,
   constraint PK_LOAN_TYPE primary key (LOAN_TYPE_ID)
)
go

/*==============================================================*/
/* Table: DATA.REPAYMENT_SCHEDULE                                    */
/*==============================================================*/
create table DATA.REPAYMENT_SCHEDULE (
   CREDIT_NO            numeric              not null,
   INSTALLMENT_NO       int                  not null,
   INSTALLMENT_DATE     date                 not null,
   INSTALLMENT_SUM      numeric(10,2)        not null,
   INSTALLMENT_PRINCIPLE numeric(10,2)        not null,
   INSTALLMENT_INTEREST numeric(10,2)        not null,
   INSTALLMENT_RESTSUM  numeric(10,2)        not null,
   MODIFIED_ON          date                 null,
   MODIFIED_BY          varchar(50)          null,
   constraint PK_REPAYMENT_SCHEDULE primary key (CREDIT_NO, INSTALLMENT_NO)
)
go

/*==============================================================*/
/* Table: DATA.STATUS                                                */
/*==============================================================*/
create table DATA.STATUS (
   STATUS_CODE          char(1)              not null,
   STATUS_NAME          varchar(100)         not null,
   constraint PK_STATUS primary key (STATUS_CODE)
)
go

alter table DATA.CLIENT
   add constraint FK_CLIENT_REFERENCE_EDUCATIO foreign key (EDU_CODE)
      references DATA.EDUCATION (EDU_CODE)
go

alter table DATA.CLIENT
   add constraint FK_CLIENT_REFERENCE_MARITAL_ foreign key (MSTATUS_CODE)
      references DATA.MARITAL_STATUS (MSTATUS_CODE)
go

alter table DATA.CLIENT_ADDRESS
   add constraint FK_CLIENT_A_REFERENCE_CLIENT foreign key (CLIENT_ID)
      references DATA.CLIENT (CLIENT_ID)
go

alter table DATA.CREDIT
   add constraint FK_CREDIT_REFERENCE_CLIENT foreign key (CLIENT_ID)
      references DATA.CLIENT (CLIENT_ID)
go

alter table DATA.CREDIT
   add constraint FK_CREDIT_REFERENCE_STATUS foreign key (STATUS_CODE)
      references DATA.STATUS (STATUS_CODE)
go

alter table DATA.CREDIT
   add constraint FK_CREDIT_REFERENCE_LOAN_TYP foreign key (LOAN_TYPE_ID)
      references DATA.LOAN_TYPE (LOAN_TYPE_ID)
go

alter table DATA.REPAYMENT_SCHEDULE
   add constraint FK_REPAYMEN_REFERENCE_CREDIT foreign key (CREDIT_NO)
      references DATA.CREDIT (CREDIT_NO)
         on delete cascade
go
