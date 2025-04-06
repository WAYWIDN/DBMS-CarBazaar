
create schema Car_Bazaar;
set search_path to Car_Bazaar;
create table company (
    CompanyID varchar(10) primary key,
    Company_Name varchar(20) not null unique,
    Country varchar(20)  not null,
    Global_Rank integer  not null unique
);


create table car (
    CarID varchar(10) primary key,
    Car_Name varchar(20)  not null ,
    Car_Type varchar(20)  not null ,
    Model varchar(20)  not null unique,

    CompanyID varchar(10)  not null 
    references company(CompanyID) 
    on update cascade on delete set null,


    Year integer  not null ,
    Transmission_Type varchar(20)  not null ,
    Seating_capacity integer  not null ,
    Fuel_Capacity numeric  not null,
    Colour varchar(15)  not null ,
    Fuel_Type varchar(15)  not null ,
    Safety_Rating numeric  not null ,
    Max_Speed numeric  not null ,
    Mileage numeric  not null ,
    Air_Bags numeric not null,
    Sunroof boolean  not null 
);

create table seller (
    SellerID varchar(10) primary key,
    Password varchar(15)  not null,
    Seller_FName varchar(15)  not null ,
    Seller_LName varchar(15)  not null ,
    Gender varchar(10) not null,
    Seller_Type varchar(20) not null,
    E_mail varchar(30) not null,
    Seller_Rating numeric,
    District varchar(25),
    City varchar(25),
    State varchar(25) not null
);

create table seller_contact (
    SellerID varchar(10) references seller(SellerID) on update cascade on delete cascade,
    Contact_No integer not null unique
);
create table availablecars (
    MID varchar(10) not null unique,
    CarID varchar(10) not null references car(CarID) on update cascade on delete set null
);
create table new_car (
    MID varchar(10) primary key references availablecars(MID) on update cascade on delete cascade,
    SellerID varchar(10) not null references seller(SellerID) on update cascade on delete cascade,
    NPrice numeric not null,
    IsSold boolean not null
);

create table old_car (
    MID varchar(10) primary key references availablecars(MID) on update cascade on delete cascade,
    SellerID varchar(10) not null references seller(SellerID) on update cascade on delete cascade,
    OPrice numeric not null,
    Kmdriven numeric not null,
    Time_Used numeric not null,
    StateCode varchar(2) not null,
    RTOCode varchar(2) not null,
    SeriesCode varchar(2) not null,
    VehicleNumber varchar(4) not null,
    IsSold boolean not null
);


create table accessory_details (
    ADetailID varchar(10) primary key,
    AName varchar(20) not null,
    Material varchar(20),
    Manufacturer varchar(20) not null,
    Description varchar(100)
);

create table accessories (
    AID varchar(10) primary key,
    ADetailID varchar(10)  not null references accessory_details(ADetailID) on update cascade on delete cascade,
    Seller_ID varchar(10) not null references seller(SellerID) on update cascade on delete set null,
    Price numeric not null,
    InStock boolean not null
    );



create table users(
    UserID varchar(10) primary key,
    Password varchar(15) not null,
    User_FName varchar(15) not null,
    User_LName varchar(15) not null,
    Gender varchar(10) not null,
    Contact_No integer not null unique,
    Age numeric not null,
    E_mail varchar(30) not null unique,
    District varchar(25) ,
    City varchar(25),
    State varchar(25) not null
);




create table market (
    ItemID varchar(10) primary key
    references new_car(MID) on update cascade on delete cascade
    references old_car(MID) on update cascade on delete cascade
    references accessories(AID) on update cascade on delete cascade,
    IsCar boolean not null
);


create table orders (
    OrderID varchar(10) primary key,
    UserID varchar(10) not null references users(UserID) on update cascade on delete cascade,
    ItemID varchar(10) not null unique references market(ItemID) on update cascade on delete cascade,
    Quantity integer not null,
    "Date" date not null,
    Payment_Type varchar(20) not null
);

create table wishlist (
    UserID varchar(10) not null unique references users(UserID) on update cascade on delete cascade,
    ItemID varchar(10) not null unique references market(ItemID) on update cascade on delete cascade,
    Date_Added date not null
);

create table review (
    ItemID varchar(10) not null unique references orders(ItemID) on update cascade on delete set null,
    UserID varchar(10) not null references users(UserID) on update cascade on delete set null,
    "Date" date not null ,
    Rating numeric not null ,
    Comments varchar(150) not null 
);


create table service (
    MID varchar(10) primary key references orders(ItemID) on update cascade on delete cascade,
    UserID varchar(10) not null references users(UserID) on update cascade on delete cascade,
    ServiceProviderID varchar(10) not null,
    "Start_Date" date not null unique,
    End_Date date not null ,
    "Status" varchar(10) not null ,
    Charges numeric not null 
);