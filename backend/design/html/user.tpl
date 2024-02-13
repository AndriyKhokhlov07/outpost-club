{* Вкладки *}
{capture name=tabs}
	<li class="active"><a href="index.php?module=UsersAdmin">Guests</a></li>
	<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
	<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
	{if in_array('issues', $manager->permissions)}<li><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>{/if}
	{if in_array("menu_12", $manager->permissions)}
		<li><a href='?module=PagesAdmin&menu_id=12'>For House Leader</a></li>
	{/if}
	
	{*
	{if in_array('groups', $manager->permissions)}<li><a href="index.php?module=GroupsAdmin">Groups</a></li>{/if}
	{if in_array('coupons', $manager->permissions)}<li><a href="index.php?module=CouponsAdmin">Купоны</a></li>{/if}
	*}
{/capture}

{if $user->id}
{$meta_title = $user->name|escape scope=parent}
{/if}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">
		{if $message_success=='updated'}
			Guest updated
		{elseif $message_success=='added'}
			Guest added
		{else}
			{$message_success|escape}
		{/if}
	</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Return</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error=='login_exists'}Пользователь с таким email уже зарегистрирован
	{elseif $message_error=='empty_name'}Введите имя пользователя
	{elseif $message_error=='empty_email'}Введите email пользователя
	{else}{$message_error|escape}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Return</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product>
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$user->name|escape}"/> 
		<input name=id type="hidden" value="{$user->id|escape}"/> 
		<div class="checkbox">
			<input name="enabled" value='1' type="checkbox" id="active_checkbox" {if $user->enabled}checked{/if}/> <label for="active_checkbox">Enabled</label>
		</div>
	</div> 
	

<div id=column_left>
	<!-- Левая колонка свойств товара -->

		<!-- Параметры страницы -->
		<div class="block">
			<ul>
				<li>
					<label class=property>Profile type</label>
					<select name="type">
						<option value='1' {if $user->type==1}selected{/if}>Guest</option>
						<option value='2' {if $user->type==2}selected{/if}>House Leader</option>
						<option value='3' {if $user->type==3}selected{/if}>Cleaner</option>
					</select>
				</li>

				{if $groups}
				<li>
					<label class=property>Group</label>
					<select name="group_id">
						<option value='0'>Not in the group</option>
				   		{foreach from=$groups item=g}
				        	<option value='{$g->id}' {if $user->group_id == $g->id}selected{/if}>{$g->name|escape}</option>
				    	{/foreach}
					</select>
				</li>
				{/if}
				<li>
					<label class=property>Email</label>
					<input name="email" class="backend_inp" type="text" value="{$user->email|escape}" />
				</li>

				{if $houses}
				<li>
					<label class=property>House</label>
					<select name="house_id">
						<option value='0'>--- Not selected ---</option>
				   		{foreach $houses as $city}
				   			{if $city->subcategories}
					   			<optgroup label="{$city->name|escape}">
					   			{foreach $city->subcategories as $r}
					        		<option value='{$r->id}'{if $user->house_id==$r->id} selected{/if}>{$r->name|escape}</option>
					        	{/foreach}
					        	</optgroup>
				        	{/if}
				    	{/foreach}
					</select>
				</li>
				{/if}

				{if !$user->id}
					<li>
						<label class=property>Password (<a class="generate_pass" href="#">generate</a>)</label><input name="password" class="backend_inp" type="text" value="Welcome" />
					</li>
				{/if}
				<li><label class=property>Registration date</label><input name="email" class="backend_inp" type="text" disabled value="{$user->created|date}" /></li>
				<li><label class=property>Last IP</label><input name="email" class="backend_inp" type="text" disabled value="{$user->last_ip|escape}" /></li>
			</ul>
		</div>


		
		<!-- Параметры страницы (The End)-->			
		
	<input class="button_green button_save" type="submit" name="user_info" value="Save" />
</div>
		
	 
	<!-- Левая колонка свойств товара (The End)--> 
	
		
</form>
<!-- Основная форма (The End) -->
 

{if $orders}
<div class="block" id=column_left>
<form id="list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	<h2>Заказы пользователя</h2>

	<div>		
		{foreach $orders as $order}
		<div class="{if $order->paid}green{/if} row">
	 		<div class="checkbox cell">
				<input type="checkbox" name="check[]" value="{$order->id}" />				
			</div>
			<div class="order_date cell">
				{$order->date|date} {$order->date|time}
			</div>
			<div class="name cell">
				<a href="{url module=OrderAdmin id=$order->id return=$smarty.server.REQUEST_URI}">Заказ №{$order->id}</a>
			</div>
			<div class="name cell">
				{$order->total_price}&nbsp;{$currency->sign}
			</div>
			<div class="icons cell">
				{if $order->paid}
					<img src='design/images/cash_stack.png' alt='Оплачен' title='Оплачен'>
				{else}
					<img src='design/images/cash_stack_gray.png' alt='Не оплачен' title='Не оплачен'>				
				{/if}	
			</div>
			<div class="icons cell">
				<a href='#' class=delete></a>		 	
			</div>
			<div class="clear"></div>
		</div>
		{/foreach}
	</div>

	<div id="action">
	<label id='check_all' class='dash_link'>Выбрать все</label>

	<span id=select>
	<select name="action">
		<option value="delete">Удалить</option>
	</select>
	</span>


	<input id="apply_action" class="button_green" name="user_orders" type="submit" value="Применить">
	</form>
	</div>
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

	// Удалить 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form#list").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form#list").submit();
	});

	// Подтверждение удаления
	$("#list").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Подтвердите удаление'))
			return false;	
	});

function generate(len)
{
   var ints =[0,1,2,3,4,5,6,7,8,9]; 
   var chars=['a','b','c','d','e','f','g','h','j','k','l','m','n','o','p','r','s','t','u','v','w','x','y','z'];
    var out='';
    for(var i=0;i<len;i++){
        var ch=Math.random(1,2);
        if(ch<0.5){
           var ch2=Math.ceil(Math.random(1,ints.length)*10);
           out+=ints[ch2-1];
        }else{
           var ch2=Math.ceil(Math.random(1,chars.length)*10);
           out+=chars[ch2-1];         
        }
    }
    return out;
}

$('.generate_pass').click(function(){
	$('input[name=password]').attr('value',generate(16));
	return false;
});

});

</script>
{/literal}
