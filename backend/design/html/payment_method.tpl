{* Вкладки *}
{capture name=tabs}
	{if in_array('settings', $manager->permissions)}<li><a href="index.php?module=SettingsAdmin">Settings</a></li>{/if}
	{if in_array('currency', $manager->permissions)}<li><a href="index.php?module=CurrencyAdmin">Currencies</a></li>{/if}
	{if in_array('delivery', $manager->permissions)}<li><a href="index.php?module=DeliveriesAdmin">Shipping</a></li>{/if}
	<li class="active"><a href="index.php?module=PaymentMethodsAdmin">Payment</a></li>
	{if in_array('managers', $manager->permissions)}<li><a href="index.php?module=ManagersAdmin">Managers</a></li>{/if}
{/capture}

{if $payment_method->id}
{$meta_title = $payment_method->name scope=parent}
{else}
{$meta_title = 'New payment method' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script>
$(function() {
	$('div#module_settings').filter(':hidden').find("input, select, textarea").attr("disabled", true);

	$('select[name=module]').change(function(){
		$('div#module_settings').hide().find("input, select, textarea").attr("disabled", true);
		$('div#module_settings[module='+$(this).val()+']').show().find("input, select, textarea").attr("disabled", false);
	});
});


</script>


{/literal}



{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{$message_success}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_success == 'added'}{$payment_method->name|escape} was created{elseif $message_success == 'updated'}{$payment_method->name|escape} was updated{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$payment_method->name|escape}"/> 
		<input name=id type="hidden" value="{$payment_method->id}"/> 
		<div class="checkbox">
			<input name=enabled value='1' type="checkbox" id="active_checkbox" {if $payment_method->enabled}checked{/if}/> <label for="active_checkbox">Enabled</label>
		</div>
	</div> 

	<div id="product_categories">
		<select name="module">
            <option value='null'>Manual processing</option>
       		{foreach $payment_modules as $payment_module}
            	<option value='{$payment_module@key|escape}' {if $payment_method->module == $payment_module@key}selected{/if} >{$payment_module->name|escape}</option>
        	{/foreach}
		</select>
	</div>
	
	<div id="product_brand">
		<label>Currency</label>
		<div>
		<select name="currency_id">
			{foreach $currencies as $currency}
            <option value='{$currency->id}' {if $currency->id==$payment_method->currency_id}selected{/if}>{$currency->name|escape}</option>
            {/foreach}
		</select>
		</div>
	</div>
	
	<!-- Левая колонка свойств товара -->
	<div id="column_left">
	
   		{foreach $payment_modules as $payment_module}
        	<div class="block layer" {if $payment_module@key!=$payment_method->module}style='display:none;'{/if} id=module_settings module='{$payment_module@key}'>
			<h2>{$payment_module->name}</h2>
			{* Параметры модуля оплаты *}
			<ul>
			{foreach $payment_module->settings as $setting}
				{$variable_name = $setting->variable}
				{if $setting->options|@count>1}
				<li><label class=property>{$setting->name}</label>
				<select name="payment_settings[{$setting->variable}]">
					{foreach $setting->options as $option}
					<option value='{$option->value}' {if $option->value==$payment_settings[$setting->variable]}selected{/if}>{$option->name|escape}</option>
					{/foreach}
				</select>
				</li>
				{elseif $setting->options|@count==1}
				{$option = $setting->options|@first}
				<li><label class="property" for="{$setting->variable}">{$setting->name|escape}</label><input name="payment_settings[{$setting->variable}]" class="simpla_inp" type="checkbox" value="{$option->value|escape}" {if $option->value==$payment_settings[$setting->variable]}checked{/if} id="{$setting->variable}" /> <label for="{$setting->variable}">{$option->name}</label></li>
				{else}
				<li><label class="property" for="{$setting->variable}">{$setting->name|escape}</label><input name="payment_settings[{$setting->variable}]" class="simpla_inp" type="text" value="{$payment_settings[$setting->variable]|escape}" id="{$setting->variable}"/></li>
				{/if}
			{/foreach}
			</ul>
			{* END Параметры модуля оплаты *}
        	
        	</div>
    	{/foreach}
    	<div class="block layer" {if $payment_method->module != ''}style='display:none;'{/if} id=module_settings module='null'></div>

	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка -->
	<div id="column_right">
		<div class="block layer">
		<h2>Related shipping methods</h2>
		<ul>
		{foreach $deliveries as $delivery}
			<li>
			<input type=checkbox name="payment_deliveries[]" id="delivery_{$delivery->id}" value='{$delivery->id}' {if in_array($delivery->id, $payment_deliveries)}checked{/if}> <label for="delivery_{$delivery->id}">{$delivery->name}</label><br>
			</li>
		{/foreach}
		</ul>		
		</div>
	</div>
	<!-- Правая колонка (The End)--> 
	
	<!-- Описагние товара -->
	<div class="block layer">
		<h2>Description</h2>
		<textarea name="description" class="editor_small">{$payment_method->description|escape}</textarea>
	</div>
	<!-- Description товара (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

