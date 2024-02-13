{capture name=tabs}
	<li class="active"><a href="index.php?module=SettingsAdmin">Settings</a></li>
	{if in_array('currency', $manager->permissions)}<li><a href="index.php?module=CurrencyAdmin">Currencies</a></li>{/if}
	{if in_array('delivery', $manager->permissions)}<li><a href="index.php?module=DeliveriesAdmin">Shipping</a></li>{/if}
	{if in_array('payment', $manager->permissions)}<li><a href="index.php?module=PaymentMethodsAdmin">Payment</a></li>{/if}
	{if in_array('managers', $manager->permissions)}<li><a href="index.php?module=ManagersAdmin">Managers</a></li>{/if}
{/capture}
 
{$meta_title = "Settings" scope=parent}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'saved'}Settings saved{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error == 'watermark_is_not_writable'}Set writable permissions to the file {$config->watermark_file}{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}
			

<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
			
		<!-- Параметры -->
		<div class="block">
			<h2>Website settings</h2>
			<ul>
				<li><label class=property>Store name</label><input name="site_name" class="simpla_inp" type="text" value="{$settings->site_name|escape}" /></li>
				<li><label class=property>Company name</label><input name="company_name" class="simpla_inp" type="text" value="{$settings->company_name|escape}" /></li>
				<li><label class=property>Date format</label><input name="date_format" class="simpla_inp" type="text" value="{$settings->date_format|escape}" /></li>
				<li><label class=property>Password remind email</label><input name="admin_email" class="simpla_inp" type="text" value="{$settings->admin_email|escape}" /></li>
			</ul>
		</div>
		<div class="block layer">
			<h2>Notification settings</h2>
			<ul>
				<li><label class=property>Orders (Invoices)</label><input name="order_email" class="simpla_inp" type="text" value="{$settings->order_email|escape}" /></li>

				<li><label class=property>Checklists</label><input name="checklists_email" class="simpla_inp" type="text" value="{$settings->checklists_email|escape}" /></li>

				<li>
					<label class=property>Restocking</label>
					<input name="restocking_email" class="simpla_inp" type="text" value="{$settings->restocking_email|escape}" />
				</li>

				<li>
					<label class=property>Kitchen restocking</label>
					<input name="krestocking_email" class="simpla_inp" type="text" value="{$settings->krestocking_email|escape}" />
				</li>

				

				<li><label class=property>Comments</label><input name="comment_email" class="simpla_inp" type="text" value="{$settings->comment_email|escape}" /></li>

				<li><label class=property>Website name</label><input name="notify_from_email" class="simpla_inp" type="text" value="{$settings->notify_from_email|escape}" /></li>
			</ul>
		</div>
		<!-- Параметры (The End)-->

		<!-- Параметры -->
		<div class="block layer">
			<h2>Price format</h2>
			<ul>
				<li><label class=property>Cents separator</label>
					<select name="decimals_point" class="simpla_inp">
						<option value='.' {if $settings->decimals_point == '.'}selected{/if}>point: 12.45 {$currency->sign|escape}</option>
						<option value=',' {if $settings->decimals_point == ','}selected{/if}>comma: 12,45 {$currency->sign|escape}</option>
					</select>
				</li>
				<li><label class=property>Thousands separator</label>
					<select name="thousands_separator" class="simpla_inp">
						<option value='' {if $settings->thousands_separator == ''}selected{/if}>no separator: 1245678 {$currency->sign|escape}</option>
						<option value=' ' {if $settings->thousands_separator == ' '}selected{/if}>space: 1 245 678 {$currency->sign|escape}</option>
						<option value=',' {if $settings->thousands_separator == ','}selected{/if}>comma: 1,245,678 {$currency->sign|escape}</option>
					</select>
				
				
				</li>
			</ul>
		</div>
		<!-- Параметры (The End)-->
		
		<!-- Параметры -->
		<div class="block layer">
			<h2>Catalog settings</h2>
			<ul>
				<li><label class=property>Products per page in frontend</label><input name="products_num" class="simpla_inp" type="text" value="{$settings->products_num|escape}" /></li>
				<li><label class=property>Products per page in backend</label><input name="products_num_admin" class="simpla_inp" type="text" value="{$settings->products_num_admin|escape}" /></li>
				<li><label class=property>Maximum amount to order</label><input name="max_order_amount" class="simpla_inp" type="text" value="{$settings->max_order_amount|escape}" /></li>
				<li><label class=property>Units</label><input name="units" class="simpla_inp" type="text" value="{$settings->units|escape}" /></li>
			</ul>
		</div>
		<!-- Параметры (The End)-->
		
		<!-- Параметры -->
		<div class="block layer">
			<h2>Products images</h2>
			
			<ul>
				<li><label class=property>Watermark</label>
				<input name="watermark_file" class="simpla_inp" type="file" />

				<img style='display:block; border:1px solid #d0d0d0; margin:10px 0 10px 0;' src="{$config->root_url}/{$config->watermark_file}?{math equation='rand(10,10000)'}">
				</li>
				<li><label class=property>Watermark offset X</label><input name="watermark_offset_x" class="simpla_inp" type="text" value="{$settings->watermark_offset_x|escape}" /> %</li>
				<li><label class=property>Watermark offset Y</label><input name="watermark_offset_y" class="simpla_inp" type="text" value="{$settings->watermark_offset_y|escape}" /> %</li>
				<li><label class=property>Watermark transparency</label><input name="watermark_transparency" class="simpla_inp" type="text" value="{$settings->watermark_transparency|escape}" /> %</li>
				<li><label class=property>Image sharpen</label><input name="images_sharpen" class="simpla_inp" type="text" value="{$settings->images_sharpen|escape}" /> %</li>
			</ul>
		</div>
		<!-- Параметры (The End)-->

		
		<!-- Параметры -->
		<div class="block layer">
			<h2>Integration with <a href="http://prostiezvonki.ru">prostiezvonki.ru</a></h2>
			<ul>
				<li><label class=property>Server</label><input name="pz_server" class="simpla_inp" type="text" value="{$settings->pz_server|escape}" /></li>
				<li><label class=property>Password</label><input name="pz_password" class="simpla_inp" type="text" value="{$settings->pz_password|escape}" /></li>
				<li><label class=property>Phone numbers:</label></li>
				{foreach $managers as $manager}
				<li><label class=property>{$manager->login}</label><input name="pz_phones[{$manager->login}]" class="simpla_inp" type="text" value="{$settings->pz_phones[$manager->login]|escape}" /></li>
				{/foreach}
			</ul>
		</div>
		<!-- Параметры (The End)-->
		
		<input class="button_green button_save" type="submit" name="save" value="Save settings" />
			
	<!-- Левая колонка свойств товара (The End)--> 
	
</form>
<!-- Основная форма (The End) -->

{literal}
<script>
$(function() {
	$('#change_password_form').hide();
	$('#change_password').click(function() {
		$('#change_password_form').show();
	});
});
</script>
{/literal}
