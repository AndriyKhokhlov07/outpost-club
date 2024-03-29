{* Вкладки *}
{capture name=tabs}
	{if in_array('products', $manager->permissions)}<li><a href="index.php?module=ProductsAdmin">Products</a></li>{/if}
	{if in_array('categories', $manager->permissions)}<li><a href="index.php?module=CategoriesAdmin">Categories</a></li>{/if}
	<li class="active"><a href="index.php?module=BrandsAdmin">Brands</a></li>
	{if in_array('features', $manager->permissions)}<li><a href="index.php?module=FeaturesAdmin">Features</a></li>{/if}
{/capture}

{* Title *}
{$meta_title='Brands' scope=parent}

{* Заголовок *}
<div id="header">
	<h1>Brands</h1> 
	<a class="add" href="{url module=BrandAdmin return=$smarty.server.REQUEST_URI}">Add new brand</a>
</div>	

{if $brands}
<div id="main_list" class="brands">

	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
		
		<div id="list" class="brands">	
			{foreach $brands as $brand}
			<div class="row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$brand->id}" />				
				</div>
				<div class="cell">
					<a href="{url module=BrandAdmin id=$brand->id return=$smarty.server.REQUEST_URI}">{$brand->name|escape}</a> 	 			
				</div>
				<div class="icons cell">
					<a class="preview" title="Preview in new window" href="../brands/{$brand->url}" target="_blank"></a>				
					<a class="delete"  title="Delete" href="#"></a>
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
</div>
{else}
No brands
{/if}

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
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Delete
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest("div.row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
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
