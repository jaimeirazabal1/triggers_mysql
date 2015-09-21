
DELIMITER //
CREATE TRIGGER `Task_insert_trig` AFTER INSERT ON `ps_orders`
FOR EACH ROW BEGIN
IF (new.id_currency = 1) THEN


SET @moneda := 'USD00001';
SET @numero_orden_actual := (SELECT typeno FROM  tum12607_maracay.systypes WHERE systypes.typeid='30');
SET @numero_orden_siguiente := @numero_orden_actual + 1;
UPDATE tum12607_maracay.systypes set typeno = @numero_orden_siguiente where systypes.typeid='30';

elseif (new.id_currency = 2) THEN


SET @moneda := 'COP00001';
SET @numero_orden_actual :=  (SELECT typeno FROM  tum12607_maracay.systypes WHERE systypes.typeid='30');
SET @numero_orden_siguiente := @numero_orden_actual + 1;
UPDATE tum12607_maracay.systypes set typeno = @numero_orden_siguiente where systypes.typeid='30';

ELSEIF (new.id_currency = 3) THEN

SET @moneda := 'VEF00001';
SET @numero_orden_actual :=  (SELECT typeno FROM  tum12607_maracay.systypes WHERE systypes.typeid='30');
SET @numero_orden_siguiente :=  @numero_orden_actual + 1;
UPDATE tum12607_maracay.systypes set typeno = @numero_orden_siguiente where systypes.typeid='30';

END IF;
INSERT into tum12607_maracay.salesorders (`orderno`,`debtorno`,`branchcode`,`customerref`,`buyername`,`comments`,
 `orddate`,`ordertype`,`shipvia`,`deladd1`,`deladd2`,`deladd3`,`deladd4`,
 `deladd5`,`deladd6`,`contactphone`,`contactemail`,`deliverto`,`deliverblind`,
 `freightcost`,`fromstkloc`,`deliverydate`,`confirmeddate`,`printedpackingslip`,
 `datepackingslipprinted`,`quotation`,`quotedate`,`id_order`)

VALUES

(@numero_orden_actual,@moneda,@moneda,'indefinido',null,'faltan los comentarios',NEW.date_add,
'01','1','INDEFINIDO','INDEFINIDO','INDEFINIDO','INDEFINIDO','INDEFINIDO','INDEFINIDO','INDEFINIDO',
'INDEFINIDO','INDEFINIDO','INDEFINIDO','0','MCY',NOW(),NOW(),'0','0000-00-00','0',NOW(),NEW.id_order);

END//
DELIMITER ;



DELIMITER //
CREATE TRIGGER `Task_insert_trig_ps_order_detail` AFTER INSERT ON `ps_order_detail`
FOR EACH ROW BEGIN
SET @contador = NULL;
SET @id_currency = (SELECT id_currency from ps_orders where id_order = new.id_order limit 1);
SET @iso_code = (SELECT iso_code from ps_currency where id_currency = @id_currency limit 1);
SET @orderno = (SELECT orderno from tum12607_maracay.salesorders order by orderno desc limit 1);
SET @contador = (SELECT orderlineno from tum12607_maracay.salesorderdetails where orderno = @orderno order by orderlineno desc limit 1);
IF @contador IS NULL THEN
SET @contador = 0;
else
SET @contador = @contador + 1;
end if;

SET @taxrate = (SELECT taxrate from tum12607_maracay.taxauthrates where currabrev = @iso_code and dispatchtaxprovince = 1);
SET @precio = (new.unit_price_tax_incl / (1 + @taxrate));
insert into tum12607_maracay.salesorderdetails (orderlineno,orderno,stkcode,qtyinvoiced,unitprice,quantity,estimate,discountpercent,actualdispatchdate,completed,narrative,itemdue,poline,commissionrate,commissionearned)
values (@contador,@orderno,new.product_reference,new.product_quantity,@precio, new.product_quantity,0,0,NOW(),0,0,0000-00-00,0,0,0);

END//
DELIMITER ;
