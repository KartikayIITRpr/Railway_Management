create or replace trigger ins_in_curr 
after insert on schedule for each row execute procedure insert_avail();