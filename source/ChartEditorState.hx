package;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import flixel.FlxG;
import flixel.FlxState;
import haxe.Json;

class ChartEditorState extends FlxState
{
	private var currentChart:ModManager.ChartData;
	private var currentChartName:String = "untitled";
	private var isDirty:Bool = false;
	
	override public function create():Void
	{
		super.create();
		
		// Inicializa um chart vazio
		currentChart = {
			songName: "New Song",
			songDiff: 0,
			songSpeed: 1.0,
			notes: [],
			bpm: 120.0,
			events: []
		};
		
		trace("[ChartEditor] Estado inicializado!");
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Ctrl+S ou Cmd+S para salvar
		#if desktop
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			saveChart();
		}
		#end
		
		// ESC para sair
		if (FlxG.keys.justPressed.ESCAPE)
		{
			confirmExit();
		}
	}
	
	public function saveChart():Void
	{
		if (!ModManager.initialized)
		{
			trace("[ChartEditor] ✗ ModManager não inicializado!");
			return;
		}
		
		if (currentChartName == "" || currentChartName == "untitled")
		{
			trace("[ChartEditor] ✗ Digite um nome para o chart!");
			return;
		}
		
		// Salva no ModManager
		if (ModManager.saveChartEditor(currentChartName, currentChart))
		{
			trace("[ChartEditor] ✓ Chart salvo: " + currentChartName);
			isDirty = false;
		}
		else
		{
			trace("[ChartEditor] ✗ Erro ao salvar chart!");
		}
	}
	
	public function loadChart(chartName:String):Void
	{
		if (!ModManager.initialized)
		{
			trace("[ChartEditor] ✗ ModManager não inicializado!");
			return;
		}
		
		var loaded = ModManager.loadChartEditor(chartName);
		
		if (loaded != null)
		{
			currentChart = loaded;
			currentChartName = chartName;
			isDirty = false;
			trace("[ChartEditor] ✓ Chart carregado: " + chartName);
		}
		else
		{
			trace("[ChartEditor] ✗ Erro ao carregar chart!");
		}
	}
	
	public function newChart(songName:String = "New Song"):Void
	{
		if (isDirty)
		{
			confirmSave();
		}
		
		currentChart = {
			songName: songName,
			songDiff: 0,
			songSpeed: 1.0,
			notes: [],
			bpm: 120.0,
			events: []
		};
		
		currentChartName = "untitled";
		isDirty = false;
		
		trace("[ChartEditor] ✓ Novo chart criado!");
	}
	
	public function addNote(time:Float, noteType:Int):Void
	{
		var note:Dynamic = {
			time: time,
			type: noteType
		};
		
		currentChart.notes.push(note);
		isDirty = true;
		
		trace("[ChartEditor] Nota adicionada no tempo: " + time);
	}
	
	public function removeNote(index:Int):Void
	{
		if (index >= 0 && index < currentChart.notes.length)
		{
			currentChart.notes.splice(index, 1);
			isDirty = true;
			trace("[ChartEditor] Nota removida!");
		}
	}
	
	public function deleteChart(chartName:String):Void
	{
		if (ModManager.deleteChartEditor(chartName))
		{
			trace("[ChartEditor] ✓ Chart deletado: " + chartName);
		}
		else
		{
			trace("[ChartEditor] ✗ Erro ao deletar chart!");
		}
	}
	
	public function getChartsList():Array<String>
	{
		return ModManager.listChartsEditor();
	}
	
	public function setSongInfo(songName:String, bpm:Float, difficulty:Int, speed:Float):Void
	{
		currentChart.songName = songName;
		currentChart.bpm = bpm;
		currentChart.songDiff = difficulty;
		currentChart.songSpeed = speed;
		isDirty = true;
	}
	
	public function getCurrentChart():ModManager.ChartData
	{
		return currentChart;
	}
	
	public function setCurrentChartName(name:String):Void
	{
		currentChartName = name;
	}
	
	private function confirmSave():Void
	{
		if (isDirty)
		{
			trace("[ChartEditor] ⚠ Chart tem mudanças não salvas!");
			// Aqui você pode implementar um popup de confirmação
			// Por enquanto, apenas salva automaticamente
			saveChart();
		}
	}
	
	private function confirmExit():Void
	{
		if (isDirty)
		{
			trace("[ChartEditor] ⚠ Deseja salvar antes de sair? (S = Sim, N = Não)");
			// Você pode implementar um popup aqui também
		}
		else
		{
			FlxG.switchState(new MainMenuState());
		}
	}
}
