create or replace function update_curr_ac (train_num int, running_on date, tot_num int )
returns void
as $$
declare
curr_coach int;
remain_seats int;
tot_ac int;
temp int;
ret_rec record;
begin
	select s.num_ac into tot_ac
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	select c.avail_seat, c.coach_num into remain_seats, curr_coach
	from curr_avail_ac c
	where c.train_num = $1 and c.running_on = $2;
	
	temp := tot_num -remain_seats;
	
	if temp < 0 then
		update curr_avail_ac as c set avail_seat = remain_seats - tot_num where c.train_num = $1 and c.running_on = $2;
	elsif temp = 0 then
		update curr_avail_ac as c set avail_seat = 18, coach_num = coach_num + 1 where c.train_num = $1 and c.running_on = $2;
	else
		update curr_avail_ac as c set avail_seat = 18-temp%18, coach_num = coach_num + (temp+17)/18 where c.train_num = $1 and c.running_on = $2;
	end if;
	
	select curr_coach, remain_seats into ret_rec;
end;
$$ language plpgsql;

create or replace function update_curr_sl (train_num int, running_on date, tot_num int )
returns void
as $$
declare
curr_coach int;
remain_seats int;
tot_ac int;
temp int;
ret_rec record;
begin
	select s.num_ac into tot_ac
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	select c.avail_seat, c.coach_num into remain_seats, curr_coach
	from curr_avail_sl c
	where c.train_num = $1 and c.running_on = $2;
	
	temp := tot_num -remain_seats;
	
	if temp < 0 then
		update curr_avail_sl as c set avail_seat = remain_seats - tot_num where c.train_num = $1 and c.running_on = $2;
	elsif temp = 0 then
		update curr_avail_sl as c set avail_seat = 24, coach_num = coach_num + 1 where c.train_num = $1 and c.running_on = $2;
	else
		update curr_avail_sl as c set avail_seat = 24-temp%24, coach_num = coach_num + (temp+23)/24 where c.train_num = $1 and c.running_on = $2;
	end if;
	
	select curr_coach, remain_seats into ret_rec;
end;
$$ language plpgsql;

create or replace function get_avail_seats (train_num int, running_on date, coach_type varchar(10), tot_num int)
returns record
as $$
declare
ans int;
remain_seats int;
curr_coach int;
tot_ac int;
tot_sl int;
ret_rec record;
temp record;
begin
	select num_ac,num_sl into tot_ac, tot_sl
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	
	if coach_type = 'AC' then 
		select * into temp
		from curr_avail_ac c
		where c.train_num = $1 and c.running_on = $2 for update;
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_ac c
		where c.train_num = $1 and c.running_on = $2;
	
	elsif coach_type = 'SL' then
		select * into temp from curr_avail_sl c where c.train_num = $1 and c.running_on = $2 for update;
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_sl c
		where c.train_num = $1 and c.running_on = $2 ;	
	end if;
	
	
	if not found then
		raise exception 'Train % not scheduled for the day %', $1, $2;
		return (-1,-1);
	end if;
	
	if coach_type = 'AC' then
		remain_seats := ans;
		ans := ans + (tot_ac - curr_coach)*18;
		if ans<tot_num then
			return (-1,-1);
		else
			perform update_curr_ac($1,$2,$4);
			select remain_seats, curr_coach into ret_rec;
			return ret_rec;
		end if;
	else
		remain_seats := ans;
		ans := ans + (tot_ac + tot_sl - curr_coach)*24;
		if ans<tot_num then
			return (-1,-1);
		else
			perform update_curr_sl($1,$2,$4);
			select remain_seats, curr_coach into ret_rec;
			return ret_rec;
		end if;
	end if;
	
end;
$$ language plpgsql;

create or replace function insert_avail() 
returns trigger
as $$
begin
	if new.num_ac >0 then
		insert into curr_avail_ac values(new.train_num, 1, new.running_on, 18);
	end if;
	
	if new.num_sl >0 then
		insert into curr_avail_sl values(new.train_num, new.num_ac+1, new.running_on, 24);
	end if;
	
	return new;
end;
$$ language plpgsql;

create or replace function get_ticket (pnr varchar(50), train_num int, for_date date, tot_num int, coach varchar(10))
returns void
as $$
declare
pnr int;
begin
	insert into ticket values($1, $2, $3, $4, $5);
end;
$$ language plpgsql;

create or replace function ins_pass (pnr varchar(50), curr_coach int, berth_num int, berth_type varchar(10), name varchar(50))
returns varchar(50)
as $$
begin
    insert into passenger values($1, $2, $3, $4, $5);
    return name;
end;
$$ language plpgsql;

