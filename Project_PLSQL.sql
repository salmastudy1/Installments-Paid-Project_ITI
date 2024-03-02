DECLARE
  cursor Installment_cursor is
    select
      contract_id,
      contract_startdate,
      contract_enddate,
      months_between(contract_startdate, contract_enddate) as Total_months,
      contract_total_fees,
      nvl(contract_deposit_fees, 0) as contract_deposit_fees,
      contract_payment_type
    from contracts;
  v_Total_months number;
  v_contract_id contracts.contract_id%TYPE;
  v_contract_startdate contracts.contract_startdate%TYPE;
  v_contract_enddate contracts.contract_enddate%TYPE;
  v_contract_total_fees contracts.contract_total_fees%TYPE;
  v_contract_deposit_fees contracts.contract_deposit_fees%TYPE;
  v_contract_payment_type contracts.contract_payment_type%TYPE;
  v_install_amount installments_paid.installment_amount%TYPE;
  v_install_date date;
  v_installment_id installments_paid.installment_id%TYPE := 1; 
  
  BEGIN
  --looping over all rows of activeset using cursor
  FOR v_install_record in Installment_cursor LOOP
    v_Total_months := v_install_record.Total_months;
    v_contract_id := v_install_record.contract_id;
    v_contract_total_fees := v_install_record.contract_total_fees;
    v_contract_deposit_fees := v_install_record.contract_deposit_fees;
    v_contract_payment_type := v_install_record.contract_payment_type;
    v_install_date := v_install_record.contract_startdate;
    
    --to check payment types(Annual, quarter, monthly, half annual)
    if v_contract_payment_type = 'ANNUAL' then
    
    v_install_amount := -(( v_contract_total_fees - v_contract_deposit_fees )* (12 / v_Total_months));
    insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
    values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
    v_installment_id := v_installment_id + 1;
    -- loop until the date is equals to the end date -12 to remove 12 months to prevent paying in the end date 
      WHILE v_install_date <> add_months(v_install_record.contract_enddate, -12)  LOOP
        v_install_date := add_months(v_install_date, 12);
        
        insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
        values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
        
        v_installment_id := v_installment_id + 1; 
      END LOOP;
      
    elsif v_contract_payment_type = 'QUARTER' then
    
    v_install_amount := -(( v_contract_total_fees - v_contract_deposit_fees )* (3 / v_Total_months));
    insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
    values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
    v_installment_id := v_installment_id + 1;
    
    --loop until the date is equals to the end date -3 to remove 3 months to prevent paying in the end date 
      WHILE v_install_date <> add_months(v_install_record.contract_enddate,-3) LOOP
        v_install_date := add_months(v_install_date, 3);
        
        insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
        values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
        
        v_installment_id := v_installment_id + 1; 
      END LOOP;
      
    elsif v_contract_payment_type = 'MONTHLY' then
    
    v_install_amount := -(( v_contract_total_fees - v_contract_deposit_fees )* (1 / v_Total_months));
    insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
    values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
    v_installment_id := v_installment_id + 1;
    
    --loop until the date is equals to the end date -1 to remove 1 month to prevent paying in the end date 
      WHILE v_install_date <> add_months(v_install_record.contract_enddate,-1) LOOP
        v_install_date := add_months(v_install_date, 1);
        
        insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
        VALUES (v_installment_id, v_contract_id, v_install_date, v_install_amount);
        
        v_installment_id := v_installment_id + 1; 
      END LOOP;
      
    elsif v_contract_payment_type = 'HALF_ANNUAL' then
    
    v_install_amount := -(( v_contract_total_fees - v_contract_deposit_fees )* (6 / v_Total_months));
    insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
    values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
    v_installment_id := v_installment_id + 1;
    
   -- loop until the date is equals to the end date -6 to remove 6 months to prevent paying in the end date 
      WHILE v_install_date <> add_months(v_install_record.contract_enddate,-6) LOOP
        v_install_date := add_months(v_install_date, 6);
        
        insert into installments_paid (installment_id, contract_id, installment_date, installment_amount)
        values (v_installment_id, v_contract_id, v_install_date, v_install_amount);
        
        v_installment_id := v_installment_id + 1; 
      END LOOP;
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Data inserted into INSTALLMENTS_PAID table successfully.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;