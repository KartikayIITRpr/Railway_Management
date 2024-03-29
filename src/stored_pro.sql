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
	elsif temp%18 = 0 then
		update curr_avail_ac as c set avail_seat = 18, coach_num = coach_num + temp/18 + 1 where c.train_num = $1 and c.running_on = $2;
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
	elsif temp%24 = 0 then
		update curr_avail_sl as c set avail_seat = 24, coach_num = coach_num + temp/24 + 1 where c.train_num = $1 and c.running_on = $2;
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
remain_seats int = -1;
curr_coach int;
tot_ac int;
tot_sl int;
ret_rec record;
temp record;
temp1 int;
up_coach int;
up_remain int;
begin
	select num_ac,num_sl into tot_ac, tot_sl
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	if coach_type = 'AC' then 
		select *
		from curr_avail_ac c
		where c.train_num = $1 and c.running_on = $2 for update into temp;
--        lock table curr_avail_ac in row exclusive mode;
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_ac c
		where c.train_num = $1 and c.running_on = $2;
		remain_seats := ans;
		ans := ans + (tot_ac - curr_coach)*18;
		if ans<tot_num then
			up_coach := curr_coach;
			up_remain := remain_seats;
			return (-1,-1);
		else
			temp1 := tot_num -remain_seats;
	
			if temp1 < 0 then
				up_coach := curr_coach;
				up_remain := remain_seats - tot_num;
			elsif temp1%18 = 0 then
				up_coach := curr_coach +  temp1/18 + 1;
				up_remain := 18;
			else
				up_coach := curr_coach + (temp1+17)/18;
				up_remain := 18-temp1%18;
			end if;
			
			select remain_seats, curr_coach into ret_rec;
		end if;

		update curr_avail_ac c set avail_seat = up_remain, coach_num = up_coach where c.train_num = $1 and c.running_on = $2;
		return ret_rec;
	
	else
--	    lock table curr_avail_sl in row exclusive mode;
		select * from curr_avail_sl c where c.train_num = $1 and c.running_on = $2 for update into temp;
		select c.avail_seat, c.coach_num into ans,curr_coach
		from curr_avail_sl c
		where c.train_num = $1 and c.running_on = $2 ;
		remain_seats := ans;
		ans := ans + (tot_ac + tot_sl - curr_coach)*24;
		if ans<tot_num then
			up_coach := curr_coach;
			up_remain := remain_seats;
			return (-1,-1);
		else
			temp1 := tot_num -remain_seats;
	
			if temp1 < 0 then
				up_coach := curr_coach;
				up_remain := remain_seats - tot_num;
			elsif temp1%24 = 0 then
				up_coach := curr_coach + temp1/24 + 1;
				up_remain := 24;
			else
				up_coach := curr_coach + (temp1+23)/24;
				up_remain := 24-temp1%24;
				update curr_avail_sl c set avail_seat = 24-temp1%24, coach_num = coach_num + (temp1+23)/24 where c.train_num = $1 and c.running_on = $2;
			end if;
	
			select remain_seats, curr_coach into ret_rec;
		end if;	
		update curr_avail_sl c set avail_seat = up_remain, coach_num = up_coach where c.train_num = $1 and c.running_on = $2;
		return ret_rec;
	end if;
	
	
	raise exception 'Train % not scheduled for the day %', $1, $2;
    return (-1,-1);

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
