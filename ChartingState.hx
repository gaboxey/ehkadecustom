class ChartingState {

    // Function to save the chart using ModManager
    public function saveChartModManager() {
        var chartData = ChartData.fromSong(_song); // Convert _song to ChartData
        ModManager.saveChartEditor(chartData);
    }

    // Function to load a chart using ModManager
    public function loadChartModManager(chartName:String) {
        var chartData = ModManager.loadChartEditor(chartName);
        // Logic to apply loaded chart data to _song
        _song = ChartData.toSong(chartData);
    }

    // Function to list available charts
    public function getChartsList():Array<String> {
        return ModManager.getAvailableCharts();
    }

    // Existing saveLevel function modification
    public function saveLevel() {
        // Existing save logic
        // ...

        // Add ModManager save
        saveChartModManager();
    }

    // Existing addSongUI function code around lines 243-246
    public function addSongUI() {
        // Existing code for the UI setup
        // ...
        
        // Save button functionality
        var saveButton = new Button();
        saveButton.onClick = function() {
            saveLevel();
        };
        // ...
    }
}