{* Вкладки *}
{capture name=tabs}

	<li {if $type==1}class="active"{/if}>
		<a href="index.php?module=InventoriesHousesAdmin&type=1">Restocking</a>
		{if $new_restokings[1]}
			<div class='counter'>{$new_restokings[1]['count']}</div>
		{/if}
	</li>
	<li {if $type==2}class="active"{/if}>
		<a href="index.php?module=InventoriesHousesAdmin&type=2">Kitchen restocking</a>
		{if $new_restokings[2]}
			<div class='counter'>{$new_restokings[2]['count']}</div>
		{/if}
	</li>

	<li><a href="index.php?module=InventoriesGroupsAdmin">Groups</a></li>
	<li><a href="index.php?module=InventoriesItemsAdmin">Items</a></li>
{/capture}



{* Title *}
{$meta_title=$house->name scope=parent}

<link href="{$config->root_url}/js/fancybox/jquery.fancybox.min.css" rel="stylesheet">
<script src="{$config->root_url}/js/fancybox/jquery.fancybox.min.js"></script>


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='updated'}Updated{else}{$message_success}{/if}</span>
</div>
<!-- Системное сообщение (The End)-->
{/if}



{* Заголовок *}
<div id="header">
	<h1>{$house->name|escape}</h1> 
</div>	


{if $groups_tree}

<form method="post">
<input type=hidden name="session_id" value="{$smarty.session.id}">
<input name=id type="hidden" value="{$default_inventory->id|escape}"/> 


<div class="inventories_block">
<input type="checkbox" name="set_default" id="set_default" {if !$default_inventory}checked{/if}>
<table class="inventories">
<tbody>
	<tr class="table_header">
		<td></td>
		<td class="i_default">
			<div class="title">Default</div>
			{if $default_inventory}
				<div class="date">{$default_inventory->date|date} {$default_inventory->date|time}</div>
			{/if}
			<label for="set_default">edit values</label>
		</td>
		{foreach $inventories as $inv}
			<td>
				{if $inv->user}
					<div class="user_name">
						<a href="?module=UserAdmin&id={$inv->user->id}">{$inv->user->name}</a>
					</div>
				{/if}
				<div class="date">{$inv->date|date} {$inv->date|time}</div>
			</td>
		{/foreach}
	</tr>
	{function name=groups_tree level=0}
		{if $groups_t}
			{foreach $groups_t as $g}

			{$subcategories_items=0}
			{if $g->subcategories}
				{foreach $g->subcategories as $sc}
					{if $sc->items}
						{$subcategories_items=1}
					{/if}
				{/foreach}
			{/if}

			{if $subcategories_items || $g->items}

				{if $g@iteration>1 && $level==0}
				<tr>
					<td colspan="{$inventories|count + 2}"></td>
				</tr>
				{/if}

				<tr class="group_name{if $level>0} ch{/if}">
					<td colspan="{$inventories|count + 2}">{$g->name|escape}</td>
				</tr>
				{groups_tree groups_t=$g->subcategories level=$level+1}
				
				{if $g->items}
					{foreach $g->items as $item}
						<tr class="tr_values">
							<td>
								{$item->name|escape},
								{if $item->unit}
									{$item->unit|escape}
								{else}
									pcs.
								{/if}
							</td>

							<!-- Default -->
							<td class="def_value">
								{if $default_inventory->values[{$g->id}][{$item->id}]}
									<div class="value">{$default_inventory->values[{$g->id}][{$item->id}]->value}</div>
									<input name="inv[{$g->id}][{$item->id}][{$default_inventory->values[{$g->id}][{$item->id}]->id}]" type="number" step="1" value="{$default_inventory->values[{$g->id}][{$item->id}]->value}">
								{else}
									<div class="value">0</div>
									<input name="inv[{$g->id}][{$item->id}][0]" type="number" step="1">
								{/if}
							</td>

							{foreach $inventories as $inv}
								<td {if $inv->view==0}class="new"{/if}>
									<div class="value">
										{$value_class=false}
										{if $inv->values[{$g->id}][{$item->id}]}
											
											{if $default_inventory->values[{$g->id}][{$item->id}]}
												{if $default_inventory->values[{$g->id}][{$item->id}]->value > $inv->values[{$g->id}][{$item->id}]->value}
													{$value_class='red'}
												{else if $default_inventory->values[{$g->id}][{$item->id}]->value < $inv->values[{$g->id}][{$item->id}]->value}
													{$value_class='green'}
												{/if}
											{/if}

											<span {if $value_class}class="{$value_class}"{/if}>{$inv->values[{$g->id}][{$item->id}]->value}</span>
										{else}
											<span {if $default_inventory->values[{$g->id}][{$item->id}]}class="red"{/if}>0</span>
										{/if}
									</div>
								</td>
							{/foreach}
						</tr>
					{/foreach}
				{/if}
			
			{/if}
			{/foreach}
		{/if}
	{/function}
	{groups_tree groups_t=$groups_tree}
	{if $isset_notes || $isset_images}
	<tr>
		<td colspan="{$inventories|count + 2}"></td>
	</tr>
	{/if}
	{if $isset_notes}
	<tr>
		<td>Note</td>
		<td></td>
		{foreach $inventories as $inv}
			<td {if $inv->view==0}class="new"{/if}>
				<div class="note">
					{$inv->note|escape}
				</div>
			</td>
		{/foreach}
	</tr>
	{/if}
	{if $isset_images}
	<tr>
		<td>Photos</td>
		<td></td>
		{foreach $inventories as $inv}
			<td {if $inv->view==0}class="new"{/if}>
				{if $inv->images}
				<div class="i_images">
					{foreach $inv->images as $i}
						<a href="{$config->root_url}/{$config->inventories_images_dir}{$i}" data-fancybox="f{$inv->id}">
							<img src="{$config->root_url}/{$config->inventories_images_dir}{$i}" alt="">
						</a>
					{/foreach}
				</div>
				{/if}
			</td>
		{/foreach}
	</tr>
	{/if}
</tbody>
</table>
<input class="button_green inventory_save" type="submit" name="" value="Save" />

</div><!-- inventories_block -->
</form>
{$show_all = 'hide'}
{include file='pagination.tpl'}	


{/if}
 
 