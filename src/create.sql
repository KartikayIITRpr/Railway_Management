create table train
(
  train_num INT NOT NULL,
  train_name varchar(50),
  primary key (train_num)
);

create table schedule(
  train_num INT NOT NULL,
  running_on DATE NOT NULL,
  num_ac INT NOT NULL,
  num_sleeper INT NOT NULL,
  primary key (train_num,running_on),
  foreign key (train_num) references train(train_num)
);

create table ticket(
 pnr serial NOT NULL,
 train_num INT NOT NULL,
 num_seats INT NOT NULL,
 coach_type varchar(10) NOT NULL,
 primary key (pnr),
 foreign key (train_num) references train (train_num)

);
 create table passenger(
  pnr INT NOT NULL,
  coach_num INT NOT NULL,
  berth_num INT NOT NULL,
  gender varchar(20),
  pas_name varchar(50),
  age INT,
  primary key (pnr,coach_num,pas_name),
  foreign key (pnr) references ticket(pnr)
 );


