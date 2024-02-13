{* Вкладки *}
{capture name=tabs}
	{if in_array('settings', $manager->permissions)}<li><a href="index.php?module=SettingsAdmin">Settings</a></li>{/if}
	{if in_array('currency', $manager->permissions)}<li><a href="index.php?module=CurrencyAdmin">Currencies</a></li>{/if}
	<li class="active"><a href="index.php?module=DeliveriesAdmin">Shipping</a></li>
	{if in_array('payment', $manager->permissions)}<li><a href="index.php?module=PaymentMethodsAdmin">Payment</a></li>{/if}
	{if in_array('managers', $manager->permissions)}<li><a href="index.php?module=ManagersAdmin">Managers</a></li>{/if}
{/capture}

{if $delivery->id}
{$meta_title = $delivery->name scope=parent}
{else}
{$meta_title = 'New shipping method' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'added'}{$delivery->name|escape} was created{elseif $message_success == 'updated'}{$delivery->name|escape} was updated{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{$message_error}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$delivery->name|escape}"/> 
		<input name=id type="hidden" value="{$delivery->id}"/> 
		<div class="checkbox">
			<input name=enabled value='1' type="checkbox" id="active_checkbox" {if $delivery->enabled}checked{/if}/> <label for="active_checkbox">Enabled</label>
		</div>
	</div> 

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
		<!-- Параметры страницы -->
		<div class="block layer">
			<h2>Shipping price</h2>
			<ul>
				<li><label class=property>Price</label><input name="price" class="simpla_small_inp" type="text" value="{$delivery->price}" /> {$currency->sign}</li>
				<li><label class=property>Free shipping over</label><input name="free_from" class="simpla_small_inp" type="text" value="{$delivery->free_from}" /> {$currency->sign}</li>
				<li><label class=property for="separate_payment">Do not include in total order price</label><input id="separate_payment" name="separate_payment" type="checkbox" value="1" {if $delivery->separate_payment}checked{/if} /></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->

	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Левая колонка свойств товара -->
	<div id="column_right">
		<div class="block layer">
		<h2>Related payment methods</h2>
		<ul>
		{foreach $payment_methods as $payment_method}
			<li>
			<input type=checkbox name="delivery_payments[]" id="payment_{$payment_method->id}" value='{$payment_method->id}' {if in_array($payment_method->id, $delivery_payments)}checked{/if}> <label for="payment_{$payment_method->id}">{$payment_method->name}</label><br>
			</li>
		{/foreach}
		</ul>		
		</div>
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Описагние товара -->
	<div class="block layer">
		<h2>Description</h2>
		<textarea name="description" class="editor_small">{$delivery->description|escape}</textarea>
	</div>
	<!-- Description товара (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

