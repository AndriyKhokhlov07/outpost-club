{* Вкладки *}
{capture name=tabs}
	{if in_array('orders', $manager->permissions)}
		<li {if $order->status==0 && ($order->type==1 || (!$order->id && $type==1))}class="active"{/if}><a href="index.php?module=OrdersAdmin&status=0&type=1">New invoices</a></li>
		<li {if $order->status==0 && ($order->type==2 || (!$order->id && $type==2))}class="active"{/if}><a href="index.php?module=OrdersAdmin&status=0&type=2">New orders</a></li>
		<li {if $order->status==1}class="active"{/if}><a href="index.php?module=OrdersAdmin&status=1">Pending</a></li>
		<li {if $order->status==2}class="active"{/if}><a href="index.php?module=OrdersAdmin&status=2">Paid</a></li>
		<li {if $order->status==3}class="active"{/if}><a href="index.php?module=OrdersAdmin&status=3">Canceled</a></li>
	{if $keyword}
	<li class="active"><a href="{url module=OrdersAdmin keyword=$keyword id=null label=null}">Search</a></li>
	{/if}
	{/if}
	{if in_array('labels', $manager->permissions)}
	<li><a href="{url module=OrdersLabelsAdmin keyword=null id=null page=null label=null}">Labels</a></li>
	{/if}
{/capture}


{if $order->id}
	{if $order->type==1}
		{$meta_title = "Invoice #`$order->id`" scope=parent}
	{elseif $order->type==2}
		{$meta_title = "Order #`$order->id`" scope=parent}
	{/if}
{else}
	{if $type==1}
		{$meta_title = "New invoice" scope=parent}
	{elseif $type==2}
		{$meta_title = "New order" scope=parent}
	{/if}
{/if}

<!-- Основная форма -->
<form method=post id=order enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">

<div id="name">
	<input name=id type="hidden" value="{$order->id|escape}"/> 
	<h1>
		{if $order->id}
			{if $order->type==1}
				Invoice
			{elseif $order->type==2}
				Order 
			{/if}
			#{$order->id|escape}
		{else}
			New 
			{if $type==1}
				invoice
			{elseif $type==2}
				order
			{/if}
		{/if}
		<select class=status name="status">
			<option value='0' {if $order->status == 0}selected{/if}>New</option>
			<option value='1' {if $order->status == 1}selected{/if}>Pending</option>
			<option value='2' {if $order->status == 2}selected{/if}>Paid</option>
			<option value='3' {if $order->status == 3}selected{/if}>Canceled</option>
		</select>
		{if $order->id}
			<a class="preview" title="Preview in new window" href="../order/{$order->url}" target="_blank">Preview</a>
		{/if}
	</h1>
	{*<a href="{url view=print id=$order->id}" target="_blank"><img src="./design/images/printer.png" name="export" title="Print invoice"></a>*}


	<div id=next_order>
		{if $prev_order}
		<a class=prev_order href="{url id=$prev_order->id}">←</a>
		{/if}
		{if $next_order}
		<a class=next_order href="{url id=$next_order->id}">→</a>
		{/if}
	</div>
		
</div> 




{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error=='error_closing'}Not enough goods in stock{else}{$message_error|escape}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{elseif $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='updated'}Order #{$order->id|escape} was updated{elseif $message_success=='added'}Order #{$order->id|escape} was created{else}{$message_success}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}



<div id="order_details">
	<div>
	<h2>Customer <a href='#' class="edit_user" {if !$order->id} style='display:none;'{/if}><img src='design/images/pencil.png' alt='Edit' title='Edit'></a> {if $user}<a href="#" class='delete_user'><img src='design/images/delete.png' alt='Remove' title='Remove'></a>{/if}</h2>
		<div class='view_user'{if !$order->id} style='display:none;'{/if}>
		{if !$user}
			Not registered
		{else}
			<a href='index.php?module=UserAdmin&id={$user->id}' target=_blank>{$user->name|escape}</a> ({$user->email|escape})
		{/if}
		</div>
		<div class='edit_user'{if $order->id} style='display:none;'{/if}>
		<input type=hidden name=user_id value='{$user->id}'>
		<input type=text id='user' class="input_autocomplete" placeholder="Select customer">
		</div>
	</div>


	<div class='layer'>

	<h2>Order details <a href='#' class="edit_order_details"><img src='design/images/pencil.png' alt='Edit' title='Edit' {if !$order->id} style='display:none;'{/if}></a></h2>
	
	<div id="user">
	<ul class="order_details">
		<li>
			<label class=property>Date</label>
			<div class="edit_order_detail view_order_detail">
			{$order->date} {$order->time}
			</div>
		</li>
		<li>
			<label class=property>Name</label> 
			<div class="edit_order_detail"{if $order->id} style='display:none;'{/if}>
				<input name="name" class="simpla_inp" type="text" value="{$order->name|escape}" />
			</div>
			<div class="view_order_detail">
				{$order->name|escape}
			</div>
		</li>
		<li>
			<label class=property>Email</label>
			<div class="edit_order_detail"{if $order->id} style='display:none;'{/if}>
				<input name="email" class="simpla_inp" type="text" value="{$order->email|escape}" />
			</div>
			<div class="view_order_detail">
				<a href="mailto:{$order->email|escape}?subject=Заказ%20№{$order->id}">{$order->email|escape}</a>
			</div>
		</li>
		<li>
			<label class=property>Phone number</label>
			<div class="edit_order_detail"{if $order->id} style='display:none;'{/if}>
				<input name="phone" class="simpla_inp " type="text" value="{$order->phone|escape}" />
			</div>
			<div class="view_order_detail">
				{if $order->phone}
				<span class="ip_call" data-phone="{$order->phone|escape}" target="_blank">{$order->phone|escape}</span>{else}{$order->phone|escape}{/if}
			</div>
		</li>
		<li>
			<label class=property>Shipping address <a href='http://maps.google.com/maps' id=address_link target=_blank><img align=absmiddle src='design/images/map.png' alt='Open map in new window' title='Open map in new window'></a></label>
			<div class="edit_order_detail"{if $order->id} style='display:none;'{/if}>
				<textarea name="address">{$order->address|escape}</textarea>
			</div>
			<div class="view_order_detail">
				{$order->address|escape}
			</div>
		</li>
		<li>
			<label class=property>Customer comment</label>
			<div class="edit_order_detail"{if $order->id} style='display:none;'{/if}>
			<textarea name="comment">{$order->comment|escape}</textarea>
			</div>
			<div class="view_order_detail">
				{$order->comment|escape|nl2br}
			</div>
		</li>
	</ul>
	</div>
	</div>

	
	{if $labels}
	<div class='layer'>
	<h2>Label</h2>
	<!-- Labels -->
	<ul>
		{foreach $labels as $l}
		<li>
		<label for="label_{$l->id}">
		<input id="label_{$l->id}" type="checkbox" name="order_labels[]" value="{$l->id}" {if in_array($l->id, $order_labels)}checked{/if}>
		<span style="background-color:#{$l->color};" class="order_label"></span>
		{$l->name}
		</label>
		</li>
		{/foreach}
	</ul>
	<!-- Labels -->
	</div>
	{/if}

	
	
	

	
	<div class='layer'>
	<h2>Your note <a href='#' class="edit_note"><img src='design/images/pencil.png' alt='Edit' title='Edit'></a></h2>
	<ul class="order_details">
		<li>
			<div class="edit_note" style='display:none;'>
				<label class=property>Your note (not visible to the user)</label>
				<textarea name="note">{$order->note|escape}</textarea>
			</div>
			<div class="view_note" {if !$order->note}style='display:none;'{/if}>
				<label class=property>Your note (not visible to the user)</label>
				<div class="note_text">{$order->note|escape}</div>
			</div>
		</li>
	</ul>
	</div>
		
</div>


<div id="purchases">
	
	<div class="block delivery" style="margin-bottom: 20px;">
		<select name="type">
			<option value='1' {if $type == 1}selected{/if}>Invoice</option>
			<option value='2' {if $type == 2}selected{/if}>Order</option>
		</select>
	</div>
	
	<div id="list" class="purchases">
		{foreach $purchases as $purchase}
		<div class="row">
			<div class="image cell">
				<input type=hidden name=purchases[id][{$purchase->id}] value='{$purchase->id}'>
				{$image = $purchase->product->images|first}
				{if $image}
				<img class=product_icon src='{$image->filename|resize:'product':35:35}'>
				{/if}
			</div>
			<div class="purchase_name cell">
			
				<div class='purchase_variant'>	

				<span class=edit_purchase style='display:none;'>
					<input class="purchase_product_name" type="text" name="purchases[product_name][{$purchase->id}]" value="{$purchase->product_name}">	
					<select name=purchases[variant_id][{$purchase->id}] {if $purchase->product->variants|count==1 && $purchase->variant_name == '' && $purchase->variant->sku == ''}style='display:none;'{/if}>					
			    	{if !$purchase->variant}<option price='{$purchase->price}' amount='{$purchase->amount}' value=''>{$purchase->variant_name|escape} {if $purchase->sku}(SKU {$purchase->sku}){/if}</option>{/if}
					{foreach $purchase->product->variants as $v}
						{if $v->stock>0 || $v->id == $purchase->variant->id}
						<option price='{$v->price}' amount='{$v->stock}' value='{$v->id}' {if $v->id == $purchase->variant_id}selected{/if} >
						{$v->name}
						{if $v->sku}(SKU {$v->sku}){/if}
						</option>
						{/if}
					{/foreach}
					</select>
				</span>
				<span class=view_purchase>
					{$purchase->variant_name} {if $purchase->sku}(SKU {$purchase->sku}){/if}			
				</span>
				</div>
		
				{if $purchase->product}
				<a class="related_product_name" href="index.php?module=ProductAdmin&id={$purchase->product->id}&return={$smarty.server.REQUEST_URI|urlencode}">{$purchase->product_name}</a>
				{else}
					<span class=view_purchase>{$purchase->product_name}</span>		
				{/if}
			</div>
			<div class="price cell">
				<span class=view_purchase>{$purchase->price}</span>
				<span class=edit_purchase style='display:none;'>
				<input type=text name=purchases[price][{$purchase->id}] value='{$purchase->price}' size=5>
				</span>
				{$currency->sign}
			</div>
			<div class="amount cell">			
				<span class=view_purchase>
					{$purchase->amount} {$settings->units}
				</span>
				<span class=edit_purchase style='display:none;'>
					{if $purchase->variant}
					{math equation="min(max(x,y),z)" x=$purchase->variant->stock+$purchase->amount*($order->closed) y=$purchase->amount z=$settings->max_order_amount assign="loop"}
					{else}
					{math equation="x" x=$purchase->amount assign="loop"}
					{/if}
			        <select name=purchases[amount][{$purchase->id}]>
						{section name=amounts start=1 loop=$loop+1 step=1}
							<option value="{$smarty.section.amounts.index}" {if $purchase->amount==$smarty.section.amounts.index}selected{/if}>{$smarty.section.amounts.index} {$settings->units}</option>
						{/section}
			        </select>
				</span>			
			</div>
			<div class="icons cell">
				<a href='#' class="delete" title="Remove"></a>		
			</div>
			<div class="clear"></div>
		</div>
		{/foreach}
		<div id="new_purchase" class="row" style='display:none;'>
			<div class="image cell">
				<input type=hidden name=purchases[id][] value=''>
				<img class=product_icon src=''>
			</div>
			<div class="purchase_name cell">
				<div class='purchase_variant'>				
					<select name=purchases[variant_id][] style='display:none;'></select>
				</div>
				<a class="purchase_name" href=""></a>
			</div>
			<div class="price cell">
				<input type=text name=purchases[price][] value='' size=5> {$currency->sign}
			</div>
			<div class="amount cell">
	        	<select name=purchases[amount][]></select>
			</div>
			<div class="icons cell">
				<a href='#' class="delete" title="Remove"></a>	
			</div>
			<div class="clear"></div>
		</div>
	</div>
	{if !$order->id && $type == 2}
 	<div id="add_purchase" {if $purchases}style='display:none;'{/if}>
 		<input type=text name=related id='add_purchase' class="input_autocomplete" placeholder='Select product'>
 	</div>
 	{/if}
	{if $purchases}
		<a href='#' class="dash_link edit_purchases">edit purchases</a>
	{/if}

	{if !$order->id && $type == 1}
	<div id="variants_block" class="purchases_items {if $purchases}hide{/if}">
		<div id="variants">
		</div>
		<ul id=new_variant style='display:none;'>
			<li class="variant_move"><div class="move_zone"></div></li>
			<li class="p_name">
				{* <input name="pitems[id][]" type="hidden" value="" /> *}
				<input name="pitems[product_name][]" type="text" value="" placeholder="Title" /></li>
			<li class="p_price">
				<input  name="pitems[price][]" type="text" value="" placeholder="Price" />
				<a class="del_variant" href=""><img src="design/images/cross-circle-frame.png" alt="" /></a>
			</li>
		</ul>
		<span class="add" id="add_variant"><i class="dash_link">Add purchase</i></span>
	</div><!-- variants_block -->
	{/if}


	{* {if $purchases} *}
	<div class="subtotal subtotal_price">
		Subtotal<b> <span class="value">{$subtotal}</span> {$currency->sign}</b>
	</div>
	{* {/if} *}

	<div class="block discount layer">
		<h2>Discount</h2>
		<input type=text name=discount value='{$order->discount}'> <span class=currency>%</span>
		<div class="subtotal">
			<b> <span class="value">{($subtotal*$order->discount/100)|round:2}</span> {$currency->sign}</b>
		</div>		
	</div>

	 
	
	<div class="block discount layer"{if (!$order->id && $type == 1) || $order->type==1} style="display:none"{/if}>
		<h2>Coupon{if $order->coupon_code} ({$order->coupon_code}){/if}</h2>
		<input type=text name=coupon_discount value='{$order->coupon_discount}'> <span class=currency>{$currency->sign}</span>		
	</div>

	<div class="subtotal layer"{if (!$order->id && $type == 1) || $order->type==1} style="display:none"{/if}>
	Price with coupon<b> {($subtotal-$subtotal*$order->discount/100-$order->coupon_discount)|round:2} {$currency->sign}</b>
	</div> 
	
	<div class="block delivery"{if (!$order->id && $type == 1) || $order->type==1} style="display:none"{/if}>
		<h2>Shipping</h2>
		<select name="delivery_id">
		<option value="0">Select shipping</option>
		{foreach $deliveries as $d}
		<option value="{$d->id}" {if $d->id==$delivery->id}selected{/if}>{$d->name}</option>
		{/foreach}
		</select>	
		<input type=text name=delivery_price value='{$order->delivery_price}'> <span class=currency>{$currency->sign}</span>
		<div class="separate_delivery">
			<input type=checkbox id="separate_delivery" name=separate_delivery value='1' {if $order->separate_delivery}checked{/if}> <label  for="separate_delivery">Do not include in total price</label>
		</div>
	</div>

	<div class="total layer">
		Total<b> <span class="value">{$order->total_price}</span> {$currency->sign}</b>
	</div>
		
		
	<div class="block payment">
		<h2>Payment method</h2>
				<select name="payment_method_id">
				<option value="0">Select payment method</option>
				{foreach $payment_methods as $pm}
				<option value="{$pm->id}" {if $pm->id==$payment_method->id}selected{/if}>{$pm->name}</option>
				{/foreach}
				</select>
		
		<input type=checkbox name="paid" id="paid" value="1" {if $order->paid}checked{/if}> <label for="paid" {if $order->paid}class="green"{/if}>Order has been paid</label>		
	</div>

 
	{if $payment_method}
	<div class="subtotal layer">
	Total to pay<b> {$order->total_price|convert:$payment_currency->id} {$payment_currency->sign}</b>
	</div>
	{/if}


	<div class="block_save">
	<input type="checkbox" value="1" id="notify_user" name="notify_user" {if !$order->id}checked{/if}>
	<label for="notify_user">Send to customer</label>

	<input class="button_green button_save" type="submit" name="" value="Save" />
	</div>


</div>


</form>
<!-- Основная форма (The End) -->


{* On document load *}
{literal}
<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>

<script>
$(function() {

	var total_price = parseInt($('.total .value').text());
	var stotal_price = parseInt($('.subtotal_price .value').text());

	$('#variants .p_price input').live('keyup', function(){
		stotal_price = 0;
		var discount_price = 0;
	    $('#variants .p_price input').each(function(){
	    	if($(this).val() != '')
	    		stotal_price += parseInt($(this).val());
	    });
	    var discount = $('.discount input').val();
		if(discount=='')
	    	discount = 0;
	    discount = parseInt(discount);

	    var discount_price = Math.round(stotal_price * discount) / 100;
	    $('.discount .subtotal .value').text(discount_price);
	    
	    total_price = stotal_price - discount_price;

	    $('.subtotal_price .value').text(stotal_price);
	    $('.total .value').text(total_price);
	});

	$('.discount input').live('keyup', function(){
		var discount = $(this).val();
		if(discount=='')
	    	discount = 0;
	    discount = parseInt(discount);
    	var discount_price = Math.round(stotal_price * discount) / 100;
    	$('.discount .subtotal .value').text(discount_price);
	    total_price = stotal_price - discount_price;
	    $('.total .value').text(total_price);

	});



	// Сортировка вариантов
	$("#variants_block").sortable({ items: '#variants ul' , axis: 'y',  cancel: '#header', handle: '.move_zone' });

	// Удаление варианта
	$('a.del_variant').click(function() {
		if($("#variants ul").size()>1)
		{
			$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		}
		else
		{
			$('#variants_block .variant_name input[name*=variant][name*=name]').val('');
			$('#variants_block .variant_name').hide('slow');
			//$('#variants_block').addClass('single_variant');
		}
		return false;
	});


	// Добавление варианта
	var variant = $('#new_variant').clone(true);
	$('#new_variant').remove().removeAttr('id');

	$(variant).clone(true).appendTo('#variants').fadeIn('slow').find("input[name*=variant][name*=name]").focus();

	$('#variants_block span.add').click(function() {
		if(!$('#variants_block').is('.single_variant'))
		{
			$(variant).clone(true).appendTo('#variants').fadeIn('slow').find("input[name*=variant][name*=name]").focus();
		}
		else
		{
			$('#variants_block .variant_name').show('slow');
			$('#variants_block').removeClass('single_variant');		
		}
		return false;		
	});




	// Раскраска строк
	function colorize()
	{
		$("#list div.row:even").addClass('even');
		$("#list div.row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
	
	// Canceledие товара
	$(".purchases a.delete").live('click', function() {
		 $(this).closest(".row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
 

	// Добавление товара 
	var new_purchase = $('.purchases #new_purchase').clone(true);
	$('.purchases #new_purchase').remove().removeAttr('id');

	$("input#add_purchase").autocomplete({
  	serviceUrl:'ajax/add_order_product.php',
  	minChars:0,
  	noCache: false, 
  	onSelect:
  		function(suggestion){
  			new_item = new_purchase.clone().appendTo('.purchases');
  			new_item.removeAttr('id');
  			new_item.find('a.purchase_name').html(suggestion.data.name);
  			new_item.find('a.purchase_name').attr('href', 'index.php?module=ProductAdmin&id='+suggestion.data.id);
  			
  			// Добавляем варианты нового товара
  			var variants_select = new_item.find('select[name*=purchases][name*=variant_id]');
			for(var i in suggestion.data.variants)
			{
				sku = suggestion.data.variants[i].sku == ''?'':' (SKU '+suggestion.data.variants[i].sku+')';
  				variants_select.append("<option value='"+suggestion.data.variants[i].id+"' price='"+suggestion.data.variants[i].price+"' amount='"+suggestion.data.variants[i].stock+"'>"+suggestion.data.variants[i].name+sku+"</option>");
  			}
  			
  			if(suggestion.data.variants.length>1 || suggestion.data.variants[0].name != '')
  				variants_select.show();
  				  				
			variants_select.bind('change', function(){change_variant(variants_select);});
				change_variant(variants_select);
  			
  			if(suggestion.data.image)
  				new_item.find('img.product_icon').attr("src", suggestion.data.image);
  			else
  				new_item.find('img.product_icon').remove();

			$("input#add_purchase").val('').focus().blur(); 
  			new_item.show();
  		},
		formatResult:
			function(suggestion, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestion.data.image?"<img align=absmiddle src='"+suggestion.data.image+"'> ":'') + suggestion.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}
  		
  });
  
  // Изменение цены и макс количества при изменении варианта
  function change_variant(element)
  {
		price = element.find('option:selected').attr('price');
		amount = element.find('option:selected').attr('amount');
		element.closest('.row').find('input[name*=purchases][name*=price]').val(price);
		
		// 
		amount_select = element.closest('.row').find('select[name*=purchases][name*=amount]');
		selected_amount = amount_select.val();
		amount_select.html('');
		for(i=1; i<=amount; i++)
			amount_select.append("<option value='"+i+"'>"+i+" {/literal}{$settings->units}{literal}</option>");
		amount_select.val(Math.min(selected_amount, amount));


		return false;
  }
  
  
	// Edit покупки
	$("a.edit_purchases").click( function() {
		 $(".purchases span.view_purchase").hide();
		 $(".purchases span.edit_purchase").show();
		 $(".edit_purchases").hide();
		 $("div#add_purchase").show();
		 return false;
	});
  
	// Edit получателя
	$("div#order_details a.edit_order_details").click(function() {
		 $("ul.order_details .view_order_detail").hide();
		 $("ul.order_details .edit_order_detail").show();
		 return false;
	});
  
	// Edit примечание
	$("div#order_details a.edit_note").click(function() {
		 $("div.view_note").hide();
		 $("div.edit_note").show();
		 return false;
	});
  
	// Edit пользователя
	$("div#order_details a.edit_user").click(function() {
		 $("div.view_user").hide();
		 $("div.edit_user").show();
		 return false;
	});
	$("input#user").autocomplete({
		serviceUrl:'ajax/search_users.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$('input[name="user_id"]').val(suggestion.data.id);

				var ou_name = $('input[name=name]');
				if(ou_name.val()=='')
					ou_name.val(suggestion.data.name);

				var ou_email = $('input[name=email]');
				if(ou_email.val()=='')
					ou_email.val(suggestion.data.email);

			}
	});
  
	// Remove пользователя
	$("div#order_details a.delete_user").click(function() {
		$('input[name="user_id"]').val(0);
		$('div.view_user').hide();
		$('div.edit_user').hide();
		return false;
	});

	// Посмотреть адрес на карте
	$("a#address_link").attr('href', 'http://maps.google.com/maps?q='+$('#order_details textarea[name="address"]').val());
  
	// Подтверждение удаления
	$('select[name*=purchases][name*=variant_id]').bind('change', function(){change_variant($(this));});
	$("input[name='status_deleted']").click(function() {
		if(!confirm('Подтвердите удаление'))
			return false;	
	});

});

</script>

<style>
.autocomplete-suggestions{
background-color: #ffffff;
overflow: hidden;
border: 1px solid #e0e0e0;
overflow-y: auto;
}
.autocomplete-suggestions .autocomplete-suggestion{cursor: default;}
.autocomplete-suggestions .selected { background:#F0F0F0; }
.autocomplete-suggestions div { padding:2px 5px; white-space:nowrap; }
.autocomplete-suggestions strong { font-weight:normal; color:#3399FF; }
</style>
{/literal}

