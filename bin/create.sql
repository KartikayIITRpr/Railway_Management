create table schedule(
  train_num INT NOT NULL,
  running_on DATE NOT NULL,
  num_ac INT NOT NULL,
  num_sl INT NOT NULL,
  primary key (train_num,running_on)
);

create table ticket(
 pnr serial NOT NULL,
 train_num INT NOT NULL,
 for_date date not null,
 num_seats INT NOT NULL,
 coach_type varchar(10) NOT NULL,
 primary key (pnr),
 foreign key (train_num, for_date) references schedule(train_num, running_on)

);
 create table passenger(
  pnr INT NOT NULL,
  coach_num INT NOT NULL,
  berth_num INT NOT NULL,
  berth_type varchar(10),
  pas_name varchar(50),
  primary key (pnr,coach_num,pas_name),
  foreign key (pnr) references ticket(pnr)
 );

 create table curr_avail_ac (
  train_num int not null,
  coach_num int not null,
  running_on date not null,
  avail_seat int not null,
  primary key (train_num, running_on),
  foreign key (train_num,running_on) references schedule (train_num, running_on)
 );
 
 
 create table curr_avail_sl (
  train_num int not null,
  coach_num int not null,
  running_on date not null,
  avail_seat int not null,
  primary key (train_num, running_on),
  foreign key (train_num,running_on) references schedule (train_num, running_on)
 );

