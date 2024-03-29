{* Вкладки *}
{capture name=tabs}
	{if in_array('products', $manager->permissions)}<li><a href="index.php?module=ProductsAdmin">Products</a></li>{/if}
	{if in_array('categories', $manager->permissions)}<li><a href="index.php?module=CategoriesAdmin">Categories</a></li>{/if}
	{if in_array('brands', $manager->permissions)}<li><a href="index.php?module=BrandsAdmin">Brands</a></li>{/if}
	<li class="active"><a href="index.php?module=FeaturesAdmin">Features</a></li>
{/capture}

{if $feature->id}
{$meta_title = $feature->name scope=parent}
{else}
{$meta_title = 'New feature' scope=parent}
{/if}

{* On document load *}
{literal}
<script>
$(function() {

 
});
</script>
{/literal}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='added'}{$feature->name|escape} was created{elseif $message_success=='updated'}{$feature->name|escape} was updated{else}{$message_success}{/if}</span>
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
<form method=post id=product>

	<div id="name">
		<input class="name" name=name type="text" value="{$feature->name|escape}"/> 
		<input name=id type="hidden" value="{$feature->id|escape}"/> 
	</div> 

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
			
		<!-- Categories -->	
		<div class="block">
			<h2>Apply to categories</h2>
					<select class=multiple_categories multiple name="feature_categories[]">
						{function name=category_select selected_id=$product_category level=0}
						{foreach $categories as $category}
								<option value='{$category->id}' {if in_array($category->id, $feature_categories)}selected{/if} category_name='{$category->single_name}'>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$category->name}</option>
								{category_select categories=$category->subcategories selected_id=$selected_id  level=$level+1}
						{/foreach}
						{/function}
						{category_select categories=$categories}
					</select>
		</div>
 
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">
		
		<!-- Параметры страницы -->
		<div class="block">
			<h2>Feature settings</h2>
			<ul>
				<li><input type=checkbox name=in_filter id=in_filter {if $feature->in_filter}checked{/if} value="1"> <label for=in_filter>Use in products filter</label></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->
		<input type=hidden name='session_id' value='{$smarty.session.id}'>
		<input class="button_green" type="submit" name="" value="Save" />
		
	</div>
	<!-- Правая колонка свойств товара (The End)--> 
	

</form>
<!-- Основная форма (The End) -->

