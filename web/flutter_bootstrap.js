{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
        let engine = await engineInitializer.initializeEngine({
            useColorEmoji: true,
        })
        await engine.runApp()
    }
})