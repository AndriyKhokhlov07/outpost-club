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

{$inv = $inventories|first}

{* Заголовок *}
<div id="header">
	<h1>{$house->name|escape}</h1> 	
</div>

{if $inv}
<div class="user_header">
	<a class="username" href="?module=UserAdmin&id={$inv->user->id}">
		<i class="fa fa-user-circle-o"></i>
		{$inv->user->name}
	</a>
	<span class="date">
		<i class="fa fa-calendar"></i>
		{$inv->date|date} {$inv->date|time}
	</span>
</div>
{/if}

{if $groups_tree}

<form method="post">
<input type=hidden name="session_id" value="{$smarty.session.id}">
<input name=id type="hidden" value="{$default_inventory->id|escape}"/> 


<div class="inventories_block">
<input type="checkbox" name="set_default" id="set_default" {if !$default_inventory}checked{/if}>


<table class="inventories v2">
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

		{$gpoups_count=0}
		{foreach $groups_tree as $k=>$g}
			{$subcategories_items=0}
			{if $g->subcategories}
				{foreach $g->subcategories as $sc}
					{if $sc->items}
						{$subcategories_items=1}
					{/if}
				{/foreach}
			{/if}
			{if $subcategories_items}
				{$gpoups_count=$gpoups_count+1}
				<td>
					<div class="title">{$g->name|escape}</div>
				</td>
			{else}
				{$groups_tree[$k]=false}
			{/if}
		{/foreach}
		<td>
			<div class="title">Total</div>
		</td>
	</tr>

	{if $first_column}
		
		{foreach $first_column as $fc_key=>$fc}
			{if $fc->t_items}
				<tr class="group_name ch">
					<td colspan="{$gpoups_count + 3}">{$fc->name}</td>
				</tr>
				{foreach $fc->t_items as $t_item}
					{$totlal=0}
					<tr class="tr_values">
						<td>
							{$t_item->name}<span class="unit">, {if $t_item->unit}{$t_item->unit|escape}{else}pcs.{/if}</span>
						</td>
						<td class="def_value">
							{if $default_inventory->values[{$fc->id}][{$t_item->id}]}
								<div class="value">
									<span data-tooltip="in kitchen">{$default_inventory->values[{$fc->id}][{$t_item->id}]->value}</span>
									/
									<span data-tooltip="in house">{$default_inventory->values[{$fc->id}][{$t_item->id}]->value * $gpoups_count}</span>
								</div>
								<input name="inv[{$fc->id}][{$t_item->id}][{$default_inventory->values[{$fc->id}][{$t_item->id}]->id}]" type="number" step="1" value="{$default_inventory->values[{$fc->id}][{$t_item->id}]->value}">
							{else}
								<div class="value">0</div>
								<input name="inv[{$fc->id}][{$t_item->id}][0]" type="number" step="1">
							{/if}
						</td>
						{foreach $groups_tree as $k=>$main_groups}
							{if $main_groups}
								<td {if $inv->view==0}class="new"{/if}>
									<div class="value">
										{$group=false}
										{if $main_groups->subcategories}
											{foreach $main_groups->subcategories as $g}
												{if $g->sign==$fc_key}
													{$group = $g}
												{/if}
											{/foreach}
										{/if}
										
										{$value_class=false}
										{if $inv->values[{$group->id}][{$t_item->id}] && $group}
											{$totlal = $totlal + $inv->values[{$group->id}][{$t_item->id}]->value}
											{if $default_inventory->values[{$fc->id}][{$t_item->id}]}
												{if $default_inventory->values[{$fc->id}][{$t_item->id}]->value > $inv->values[{$group->id}][{$t_item->id}]->value}
													{$value_class='red'}
												{else if $default_inventory->values[{$fc->id}][{$t_item->id}]->value < $inv->values[{$group->id}][{$t_item->id}]->value}
													{$value_class='green'}
												{/if}
											{/if}

											<span {if $value_class}class="{$value_class}"{/if}>{$inv->values[{$group->id}][{$t_item->id}]->value}</span>
										{else}
											<span {if $default_inventory->values[{$fc->id}][{$t_item->id}]}class="red"{/if}>0</span>
										{/if}
									</div>
								</td>
							{/if}
						{/foreach}
						<td class="total_val">
							<span class="total">{$totlal}</span>
							{if $default_inventory->values[{$fc->id}][{$t_item->id}]}
								{$sum = $totlal - ($default_inventory->values[{$fc->id}][{$t_item->id}]->value * $gpoups_count)}
								{if $sum > 0 || $sum < 0}
								<span class="sum {if $sum > 0}plus{elseif $sum < 0}minus{/if}">
									{$sum}
								</span>
								{/if}
							{/if}
						</td>
					</tr>
				{/foreach}
			{/if}
		{/foreach}
	{/if}


	{if $isset_notes || $isset_images}
	<tr>
		<td colspan="{$gpoups_count + 3}"></td>
	</tr>
	{/if}
	{if $isset_notes}
	<tr>
		<td>Note</td>
		<td colspan="{$gpoups_count + 2}" {if $inv->view==0}class="new"{/if}>
			<div class="note">
				{$inv->note|escape}
			</div>
		</td>
	</tr>
	{/if}
	{if $isset_images}
	<tr>
		<td>Photos</td>
		<td colspan="{$gpoups_count + 2}" {if $inv->view==0}class="new"{/if}>
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
 
 