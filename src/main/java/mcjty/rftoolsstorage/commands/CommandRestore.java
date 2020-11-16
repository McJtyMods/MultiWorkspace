package mcjty.rftoolsstorage.commands;

import com.mojang.brigadier.Command;
import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.StringArgumentType;
import com.mojang.brigadier.builder.ArgumentBuilder;
import com.mojang.brigadier.context.CommandContext;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import mcjty.rftoolsstorage.modules.modularstorage.items.StorageModuleItem;
import mcjty.rftoolsstorage.storage.StorageEntry;
import mcjty.rftoolsstorage.storage.StorageHolder;
import net.minecraft.command.CommandSource;
import net.minecraft.command.Commands;
import net.minecraft.item.ItemStack;
import net.minecraft.util.text.StringTextComponent;
import net.minecraft.util.text.TextFormatting;

public class CommandRestore implements Command<CommandSource> {

    private static final CommandRestore CMD = new CommandRestore();

    public static ArgumentBuilder<CommandSource, ?> register(CommandDispatcher<CommandSource> dispatcher) {
        return Commands.literal("restore")
                .requires(cs -> cs.hasPermissionLevel(2))
                .then(Commands.argument("uuid", StringArgumentType.word())
                        .executes(CMD));
    }

    @Override
    public int run(CommandContext<CommandSource> context) throws CommandSyntaxException {
        String uuidString = context.getArgument("uuid", String.class);

        ItemStack stack = context.getSource().asPlayer().getHeldItemMainhand();
        if (!(stack.getItem() instanceof StorageModuleItem)) {
            context.getSource().sendFeedback(
                    new StringTextComponent("Keep a storage module in your main hand!").modifyStyle(style -> style.applyFormatting(TextFormatting.RED)), true);
            return 0;
        }

        int maxSize = StorageModuleItem.getSize(stack);

        StorageHolder holder = StorageHolder.get(context.getSource().getWorld());
        StorageEntry foundEntry = null;
        for (StorageEntry storage : holder.getStorages()) {
            if (storage.getUuid().toString().startsWith(uuidString)) {
                if (foundEntry != null) {
                    context.getSource().sendFeedback(
                            new StringTextComponent("Multiple storage entries match this UUID part!").modifyStyle(style -> style.applyFormatting(TextFormatting.RED)), true);
                    return 0;
                }
                foundEntry = storage;
            }
        }

        if (foundEntry != null) {
            if (foundEntry.getStacks().size() != maxSize) {
                context.getSource().sendFeedback(
                        new StringTextComponent("Wrong foundEntry module tier! " + foundEntry.getStacks().size() + " stacks are required!").modifyStyle(style -> style.applyFormatting(TextFormatting.RED)), true);
            } else {
                stack.getOrCreateTag().putUniqueId("uuid", foundEntry.getUuid());
                context.getSource().asPlayer().container.detectAndSendChanges();
            }
        } else {
            context.getSource().sendFeedback(
                    new StringTextComponent("No storage found with UUID " + uuidString).modifyStyle(style -> style.applyFormatting(TextFormatting.RED)), true);
        }
        return 0;
    }
}
