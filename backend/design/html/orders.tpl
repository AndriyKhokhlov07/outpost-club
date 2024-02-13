{* Вкладки *}
{capture name=tabs}
	{if in_array('orders', $manager->permissions)}
	<li {if $status===0 && $type==1}class="active"{/if}><a href="{url module=OrdersAdmin status=0 type=1 keyword=null id=null page=null label=null}">New invoices</a></li>
	<li {if $status===0 && $type==2}class="active"{/if}><a href="{url module=OrdersAdmin status=0 type=2 keyword=null id=null page=null label=null}">New orders</a></li>
	<li {if $status==1}class="active"{/if}><a href="{url module=OrdersAdmin status=1 keyword=null id=null page=null label=null}">Pending</a></li>
	<li {if $status==2}class="active"{/if}><a href="{url module=OrdersAdmin status=2 keyword=null id=null page=null label=null}">Paid</a></li>
	<li {if $status==3}class="active"{/if}><a href="{url module=OrdersAdmin status=3 keyword=null id=null page=null label=null}">Canceled</a></li>
	{if $keyword}
	<li class="active"><a href="{url module=OrdersAdmin keyword=$keyword id=null label=null}">Search</a></li>
	{/if}
	{/if}
	{if in_array('labels', $manager->permissions)}
	<li><a href="{url module=OrdersLabelsAdmin keyword=null id=null page=null label=null}">Labels</a></li>
	{/if}
{/capture}

{* Title *}
{$meta_title='Orders' scope=parent}

{* Search *}
<form method="get">
<div id="search">
	<input type="hidden" name="module" value="OrdersAdmin">
	<input class="search" type="text" name="keyword" value="{$keyword|escape}"/>
	<input class="search_button" type="submit" value=""/>
</div>
</form>
	
{* Заголовок *}
<div id="header">
	<h1>
		{if $orders_count}
			{$orders_count}
		{else}
			No
		{/if}
		{if $type==1}invoice{$orders_count|plural:'':'s'}{elseif $type==2}order{$orders_count|plural:'':'s'}{else}invoises and orders{/if}</h1>
	{if $status===0}
		<a class="add" href="{url module=OrderAdmin}">Add new {if $type==1}invoice{elseif $type==2}order{/if}</a>
	{/if}
</div>	

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error=='error_closing'}Shortage of some goods in stock{else}{$message_error|escape}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
{/if}

{if $orders}
<div id="main_list">
	
	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->
	
	<form id="form_list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">

		<div id="list">		
			{foreach $orders as $order}
			<div class="{if $order->paid}green{/if} row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$order->id}"/>				
				</div>
				<div class="order_date cell">				 	
	 				{$order->date|date}{* at {$order->date|time} *}
				</div>
				<div class="order_name cell">
					{foreach $order->labels as $l}
					<span class="order_label" style="background-color:#{$l->color};" title="{$l->name}"></span>
					{/foreach}
	 				<a href="{url module=OrderAdmin id=$order->id return=$smarty.server.REQUEST_URI}">
	 					{if $order->type==1}
	 						Invoice
	 					{elseif $order->type==2}
	 						Order
	 					{/if}
	 					#{$order->id}</a>
	 					{$order->name|escape}
	 				{if $order->note}
	 				<div class="note">{$order->note|escape}</div>
	 				{/if} 	 			
				</div>
				<div class="icons cell">
					{* <a href='{url module=OrderAdmin id=$order->id view=print}'  target="_blank" class="print" title="Print invoice"></a> *}

					<a class="preview" title="Preview in new window" href="../order/{$order->url}" target="_blank"></a>
					<a href='#' class=delete title="Delete"></a>
				</div>
				<div class="name cell" style='white-space:nowrap;'>
	 				{$order->total_price|escape} {$currency->sign}
				</div>
				<div class="icons cell">
					{if $order->paid}
						<img src='design/images/cash_stack.png' alt='Payment accepted' title='Payment accepted'>
					{else}
						<img src='design/images/cash_stack_gray.png' alt='Waiting for payment' title='Waiting for payment'>				
					{/if}			 	
				</div>
				{if $keyword}
				<div class="icons cell">
						{if $order->status == 0}
						<img src='design/images/new.png' alt='New' title='New'>
						{/if}
						{if $order->status == 1}
						<img src='design/images/time.png' alt='Accepted' title='Accepted'>
						{/if}
						{if $order->status == 2}
						<img src='design/images/tick.png' alt='Closed' title='Closed'>
						{/if}
						{if $order->status == 3}
						<img src='design/images/cross.png' alt='Canceled' title='Canceled'>
						{/if}
				</div>
				{/if}
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
		<div id="action">
		<label id='check_all' class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			{if $status!==0}<option value="set_status_0">Move to New</option>{/if}
			{if $status!==1}<option value="set_status_1">Move to Pending</option>{/if}
			{if $status!==2}<option value="set_status_2">Move to Paid</option>{/if}
			{foreach $labels as $l}
			<option value="set_label_{$l->id}">Set label &laquo;{$l->name}&raquo;</option>
			{/foreach}
			{foreach $labels as $l}
			<option value="unset_label_{$l->id}">Unset label &laquo;{$l->name}&raquo;</option>
			{/foreach}
			<option value="delete">Delete selected orders</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		
		</div>
	</form>
	
	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->
		
</div>
{/if}

<!-- Меню -->
<div id="right_menu">

	<ul>
		<li{if !$type} class="selected"{/if}><a href="{url type=null}">All</a></li>
		<li{if $type==1} class="selected"{/if}><a href="{url type=1}">Invoices</a></li>
		<li{if $type==2} class="selected"{/if}><a href="{url type=2}">Orders</a></li>
	</ul>
	
	{if $labels}
	<!-- Labels -->
	<ul id="labels">
		<li {if !$label}class="selected"{/if}><span class="label"></span> <a href="{url label=null}">All</a></li>
		{foreach $labels as $l}
		<li data-label-id="{$l->id}" {if $label->id==$l->id}class="selected"{/if}>
		<span style="background-color:#{$l->color};" class="order_label"></span>
		<a href="{url label=$l->id}">{$l->name}</a></li>
		{/foreach}
	</ul>
	<!-- Labels -->
	{/if}
	
</div>
<!-- Меню  (The End) -->



{* On document load *}
{literal}
<script>

$(function() {

	// Сортировка списка
	$("#labels").sortable({
		items:             "li",
		tolerance:         "pointer",
		scrollSensitivity: 40,
		opacity:           0.7
	});
	

	$("#main_list #list .row").droppable({
		activeClass: "drop_active",
		hoverClass: "drop_hover",
		tolerance: "pointer",
		drop: function(event, ui){
			label_id = $(ui.helper).attr('data-label-id');
			$(this).find('input[type="checkbox"][name*="check"]').attr('checked', true);
			$(this).closest("form").find('select[name="action"] option[value=set_label_'+label_id+']').attr("selected", "selected");		
			$(this).closest("form").submit();
			return false;	
		}		
	});
	
	// Раскраска строк
	function colorize()
	{
		$("#list div.row:even").addClass('even');
		$("#list div.row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();

	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Delete 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});

	// Подтверждение удаления
	$("form").submit(function() {
		if($('#list input[type="checkbox"][name*="check"]:checked').length>0)
			if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
				return false;	
	});
});

</script>
{/literal}
