{* Вкладки *}
{capture name=tabs}
	{if in_array('users', $manager->permissions)}<li><a href="index.php?module=UsersAdmin">Customers</a></li>{/if}
	{if in_array('groups', $manager->permissions)}<li><a href="index.php?module=GroupsAdmin">Groups</a></li>{/if}
	<li class="active"><a href="index.php?module=CouponsAdmin">Coupons</a></li>
{/capture}

{* Title *}
{$meta_title='Coupons' scope=parent}
		
{* Заголовок *}
<div id="header">
	{if $coupons_count}
	<h1>{$coupons_count} {$coupons_count|plural:'coupon':'coupons'}</h1>
	{else}
	<h1>No coupons</h1>
	{/if}
	<a class="add" href="{url module=CouponAdmin return=$smarty.server.REQUEST_URI}">New coupon</a>
</div>	

{if $coupons}
<div id="main_list">
	
	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->

	<form id="form_list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	
		<div id="list">
			{foreach $coupons as $coupon}
			<div class="{if $coupon->valid}green{/if} row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$coupon->id}"/>				
				</div>
				<div class="coupon_name cell">			 	
	 				<a href="{url module=CouponAdmin id=$coupon->id return=$smarty.server.REQUEST_URI}">{$coupon->code}</a>
				</div>
				<div class="coupon_discount cell">			 	
	 				Discount {$coupon->value*1} {if $coupon->type=='absolute'}{$currency->sign}{else}%{/if}<br>
	 				{if $coupon->min_order_price>0}
	 				<div class="detail">
	 				For orders equal or over {$coupon->min_order_price|escape} {$currency->sign}
	 				</div>
	 				{/if}
				</div>
				<div class="coupon_details cell">			 	
					{if $coupon->single}
	 				<div class="detail">
	 				Single-use
	 				</div>
	 				{/if}
	 				{if $coupon->usages>0}
	 				<div class="detail">
	 				Used {$coupon->usages|escape} {$coupon->usages|plural:'time':'times'}
	 				</div>
	 				{/if}
	 				{if $coupon->expire}
	 				<div class="detail">
	 				{if $smarty.now|date_format:'%Y%m%d' <= $coupon->expire|date_format:'%Y%m%d'}
	 				Expires {$coupon->expire|date}
	 				{else}
	 				Expired {$coupon->expire|date}
	 				{/if}
	 				</div>
	 				{/if}
				</div>
				<div class="icons cell">
					<a href='#' class=delete></a>
				</div>
				<div class="name cell" style='white-space:nowrap;'>
					
	 				
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
		
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			<option value="delete">Delete</option>
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

{* On document load *}
{literal}

<script>
$(function() {

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
		$('#list input[type="checkbox"][name*="check"]').attr('checked', 1-$('#list input[type="checkbox"][name*="check"]').attr('checked'));
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