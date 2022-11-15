create or replace function get_avail_seats (train_num int, running_on date, coach_type varchar(10))
returns int
as $$
declare
ans int;
curr_coach int;
tot_ac int;
tot_sl int;
begin
	select num_ac,num_sl into tot_ac, tot_sl
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	if coach_type = 'AC' then 
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_ac c
		where c.train_num = $1 and c.running_on = $2;
	
	elsif coach_type = 'SL' then
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_sl c
		where c.train_num = $1 and c.running_on = $2 ;	
	end if;
	
	
	if not found then
		raise exception 'Train not scheduled for the day';
		return -1;
	end if;
	
	if coach_type = 'AC' then
		ans := ans + (tot_ac - curr_coach)*18;
	else
		ans := ans + (tot_ac + tot_sl - curr_coach)*24;
	end if;
	
	return ans;
	
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

create or replace function update_curr_ac (train_num int, running_on date, tot_num int )
returns void
as $$
declare
curr_coach int;
remain_seats int;
tot_ac int;
temp int;
begin
	select s.num_ac into tot_ac
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	select c.avail_seat, c.coach_num into remain_seats, curr_coach
	from curr_avail_ac c
	where c.train_num = $1 and c.running_on = $2;
	
	temp := tot_num -remain_seats;
	
	if temp < 0 then
		update curr_avail_ac
		set avail_seat = remain_seats - tot_num
		where train_num = $1 and running_on = $2;
	elsif temp == 0 then
		update curr_avail_ac
		set avail_seat = 18, coach_num = coach_num + 1
		where train_num = $1 and running_on = $2;
	else
		update curr_avail_ac
		set avail_seat = 18-temp%18, coach_num = coach_num + (temp+17)/18
		where train_num = $1 and running_on = $2;
	end if;
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
begin
	select s.num_ac into tot_ac
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	select c.avail_seat, c.coach_num into remain_seats, curr_coach
	from curr_avail_sl c
	where c.train_num = $1 and c.running_on = $2;
	
	temp := tot_num -remain_seats;
	
	if temp < 0 then
		temp := remain_seats - tot_num;
		update curr_avail_sl
		set avail_seat = 2
		where train_num = $1 and running_on = $2;
	elsif temp == 0 then
		update curr_avail_sl
		set avail_seat = 24, coach_num = coach_num + 1
		where train_num = $1 and running_on = $2;
	else
		update curr_avail_sl
		set avail_seat = 24-temp%24, coach_num = coach_num + (temp+23)/24
		where train_num = $1 and running_on = $2;
	end if;
end;
$$ language plpgsql;
