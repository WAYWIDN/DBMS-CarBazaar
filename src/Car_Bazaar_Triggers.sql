--------------------------------------------------------------------------------------------------
--------------------------------- To check Order Exists or not -----------------------------------
--------------------------------------------------------------------------------------------------

create or replace function check_order_exists()
returns trigger as 
$$
begin
    if not exists (
        select 1 from orders 
        where orders.UserID = NEW.UserID and orders.ItemID = NEW.ItemID
    ) then
        raise exception 'User % has not ordered item %!',New.UserID, NEW.ItemID;
    end if;
    return NEW;
end;
$$ 
language plpgsql;

create trigger review_insert_trigger
before insert or update on review
for each row
execute procedure check_order_exists();

--------------------------------------------------------------------------------------------------
------------------------- To check User has bought that car or not -------------------------------
--------------------------------------------------------------------------------------------------

create or replace function check_user_owns_car() 
returns trigger as 
$$
begin
    if not exists (
        select 1 from orders 
        where ItemID = NEW.MID and UserID = NEW.UserID
    ) then
        raise exception 'User % has not purchased MID %', NEW.UserID, NEW.MID;
    end if;
    return NEW;
end;
$$ language plpgsql;

create trigger service_insert_trigger
before insert or update on service
for each row
execute procedure check_user_owns_car();

--------------------------------------------------------------------------------------------------
---------------------------------- To SET isSold Flag --------------------------------------------
--------------------------------------------------------------------------------------------------

create or replace function update_isSold_flag()
returns trigger as
$$
begin
    -- Check if ItemID exists in availablecars
    if exists (select 1 from availablecars where MID = NEW.ItemID) then
        
        -- Check and Update in new_car
        if exists (select 1 from new_car where MID = NEW.ItemID) then
            update new_car set IsSold = true where MID = NEW.ItemID;
        
        -- Else Update in old_car
        elsif exists (select 1 from old_car where MID = NEW.ItemID) then
            update old_car set IsSold = true where MID = NEW.ItemID;

        end if;
        
    end if;
    
    return NEW;
end;
$$
language plpgsql;


create trigger car_sold_flag_trigger
after insert or update on orders
for each row
execute procedure update_isSold_flag();

--------------------------------------------------------------------------------------------------
----------- To validate ItemID is in New_Car or Old_Car or Accessories Table ---------------------
--------------------------------------------------------------------------------------------------

create or replace function check_itemid()
returns trigger as
$$
begin
    -- check in new_car
    if exists (select 1 from new_car where mid = new.itemid) then
        return new;
    end if;

    -- check in old_car
    if exists (select 1 from old_car where mid = new.itemid) then
        return new;
    end if;

    -- check in accessories
    if exists (select 1 from accessories where aid = new.itemid) then
        return new;
    end if;

    raise exception 'itemid % does not exist in new_car, old_car, or accessories', new.itemid;
end;
$$ language plpgsql;


create trigger trg_check_itemid
before insert or update on market
for each row
execute procedure check_itemid();





