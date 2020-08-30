package mcjty.rftoolsbuilder.modules.scanner;

import mcjty.lib.modules.IModule;
import mcjty.rftoolsbuilder.setup.Config;
import mcjty.rftoolsbuilder.shapes.ShapeDataManagerClient;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.fml.event.lifecycle.FMLClientSetupEvent;
import net.minecraftforge.fml.event.lifecycle.FMLCommonSetupEvent;

public class ScannerModule implements IModule {

    @Override
    public void init(FMLCommonSetupEvent event) {
        MinecraftForge.EVENT_BUS.register(new ShapeHandler());
    }

    @Override
    public void initClient(FMLClientSetupEvent event) {
        MinecraftForge.EVENT_BUS.addListener(ShapeDataManagerClient::cleanupOldRenderers);
    }

    @Override
    public void initConfig() {
        ScannerConfiguration.init(Config.SERVER_BUILDER, Config.CLIENT_BUILDER);
    }
}
