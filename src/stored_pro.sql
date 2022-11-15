create or replace function get_avail_seats (train_num int, running_on date, coach_type varchar(10))
returns int
as $$
declare
ans int;
curr_coach int;
tot_ac int;
tot_sl int;
begin
	select num_ac,num_sleeper into tot_ac, tot_sl
	from schedule s
	where s.train_num = $1 and s.running_on = $2;
	
	select c.avail_seat, c.coach_num into ans,curr_coach
	from curr_avail_coach c
	where c.train_num = $1 and c.running_on = $2 and c.coach_type = $3;
	
	if not found then
		return -1;
	end if;
	
	if coach_type = 'AC' then
		ans := ans + (tot_ac - curr_coach)*18;
	else
		ans := ans + (tot_ac + tot_sl - curr_coach)*18;
	end if;
	
	return ans;
	
end;
$$ language plpgsql;

create or replace function insert_curr_seat 
