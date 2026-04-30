package;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import flixel.FlxG;
import haxe.Json;

typedef ModData = {
	var name:String;
	var author:String;
	var version:String;
	var description:String;
	var charts:Array<String>;
	var enabled:Bool;
}

typedef ChartData = {
	var songName:String;
	var songDiff:Int;
	var songSpeed:Float;
	var notes:Array<Dynamic>;
	var bpm:Float;
	var events:Array<Dynamic>;
}

class ModManager
{
	public static var modsPath:String = "";
	public static var savesPath:String = "";
	public static var chartsPath:String = "";
	public static var mods:Map<String, ModData> = new Map();
	public static var initialized:Bool = false;
	
	public static function initModSystem():Void
	{
		if (initialized)
		{
			trace("[ModManager] Sistema já foi inicializado!");
			return;
		}
	
		try
		{
			#if android
				// Usa a pasta pública direto no emulated/0 após permissão
				modsPath = "/storage/emulated/0/.Kadesh/mods";
				savesPath = "/storage/emulated/0/.Kadesh/saves";
				chartsPath = "/storage/emulated/0/.Kadesh/saves/charts";
			#elseif ios
				var docsDir = lime.system.System.documentsDirectory;
				modsPath = docsDir + ".Kadesh/mods";
				savesPath = docsDir + ".Kadesh/saves";
				chartsPath = docsDir + ".Kadesh/saves/charts";
			#elseif sys
				var sep = getSeparator();
				var appDir = Sys.getCwd();
				modsPath = appDir + ".Kadesh" + sep + "mods";
				savesPath = appDir + ".Kadesh" + sep + "saves";
				chartsPath = appDir + ".Kadesh" + sep + "saves" + sep + "charts";
			#else
				modsPath = ".Kadesh/mods";
				savesPath = ".Kadesh/saves";
				chartsPath = ".Kadesh/saves/charts";
			#end
			
			trace("[ModManager] Caminho dos mods: " + modsPath);
			trace("[ModManager] Caminho dos saves: " + savesPath);
			trace("[ModManager] Caminho dos charts: " + chartsPath);
			
			createDirectories();
			loadAllMods();
			
			initialized = true;
			trace("[ModManager] ✓ Sistema de mods e saves inicializado com sucesso!");
		}
		catch (e)
		{
			trace("[ModManager] ✗ ERRO CRÍTICO ao inicializar: " + e);
			initialized = false;
		}
	}
	
	private static function getSeparator():String
	{
		#if windows
			return "\\";
		#else
			return "/";
		#end
	}
	
	private static function createDirectories():Void
	{
		#if sys
		try
		{
			if (!FileSystem.exists(modsPath))
			{
				trace("[ModManager] Criando: " + modsPath);
				createDirectoryRecursive(modsPath);
				trace("[ModManager] ✓ Pasta de mods criada!");
			}
			else
			{
				trace("[ModManager] Pasta de mods já existe.");
			}
			
			if (!FileSystem.exists(savesPath))
			{
				trace("[ModManager] Criando: " + savesPath);
				createDirectoryRecursive(savesPath);
				trace("[ModManager] ✓ Pasta de saves criada!");
			}
			
			if (!FileSystem.exists(chartsPath))
			{
				trace("[ModManager] Criando: " + chartsPath);
				createDirectoryRecursive(chartsPath);
				trace("[ModManager] ✓ Pasta de charts criada!");
			}
			
			var sep = getSeparator();
			var modsSubCharts = modsPath + sep + "charts";
			var modsSubSounds = modsPath + sep + "sounds";
			var modsSubArt = modsPath + sep + "art";
			
			createIfNotExists(modsSubCharts);
			createIfNotExists(modsSubSounds);
			createIfNotExists(modsSubArt);
			
			trace("[ModManager] ✓ Todas as pastas foram criadas/verificadas!");
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao criar diretórios: " + e);
		}
		#end
	}
	
	private static function createDirectoryRecursive(path:String):Void
	{
		#if sys
		if (FileSystem.exists(path))
			return;
		
		var sep = getSeparator();
		var parts = path.split(sep);
		var current = "";
		
		for (part in parts)
		{
			if (part == "" || part == ".")
				continue;
			
			#if windows
				if (current == "")
					current = part;
				else
					current += sep + part;
			#else
				if (current == "")
					current = sep + part;
				else
					current += sep + part;
			#end
			
			if (!FileSystem.exists(current))
			{
				try
				{
					FileSystem.createDirectory(current);
					trace("[ModManager] Criou pasta: " + current);
				}
				catch (e)
				{
					trace("[ModManager] ✗ Erro ao criar " + current + ": " + e);
					throw e;
				}
			}
		}
		#end
	}
	
	private static function createIfNotExists(path:String):Void
	{
		#if sys
		if (!FileSystem.exists(path))
		{
			try
			{
				FileSystem.createDirectory(path);
				trace("[ModManager] Criou: " + path);
			}
			catch (e)
			{
				trace("[ModManager] Aviso ao criar " + path + ": " + e);
			}
		}
		#end
	}
	
	public static function saveChartEditor(chartName:String, chartData:ChartData):Bool
	{
		#if sys
		if (!initialized)
		{
			trace("[ModManager] Sistema não foi inicializado!");
			return false;
		}

		try
		{
			var sep = getSeparator();
			var chartPath = chartsPath + sep + chartName + ".json";
			
			var json = Json.stringify(chartData, null, "  ");
			File.saveContent(chartPath, json);
			
			trace("[ModManager] ✓ Chart do editor salvo: " + chartName);
			return true;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao salvar chart: " + e);
			return false;
		}
		#else
		return false;
		#end
	}
	
	public static function loadChartEditor(chartName:String):ChartData
	{
		#if sys
		try
		{
			if (!initialized)
			{
				trace("[ModManager] Sistema não foi inicializado!");
				return null;
			}

			var sep = getSeparator();
			var chartPath = chartsPath + sep + chartName + ".json";
			
			if (!FileSystem.exists(chartPath))
			{
				trace("[ModManager] ✗ Chart não encontrado: " + chartPath);
				return null;
			}
			
			var json = File.getContent(chartPath);
			var chartData:ChartData = Json.parse(json);
			trace("[ModManager] ✓ Chart carregado: " + chartName);
			return chartData;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao carregar chart: " + e);
			return null;
		}
		#else
		return null;
		#end
	}
	
	public static function listChartsEditor():Array<String>
	{
		#if sys
		try
		{
			if (!FileSystem.exists(chartsPath))
				return [];
			
			var files = FileSystem.readDirectory(chartsPath);
			var charts:Array<String> = [];
			
			for (file in files)
			{
				if (StringTools.endsWith(file, ".json"))
				{
					var chartName = file.substr(0, file.length - 5);
					charts.push(chartName);
				}
			}
			
			return charts;
		}
		catch (e)
		{
			trace("[ModManager] Erro ao listar charts: " + e);
			return [];
		}
		#else
		return [];
		#end
	}
	
	public static function deleteChartEditor(chartName:String):Bool
	{
		#if sys
		try
		{
			if (!initialized)
			{
				trace("[ModManager] Sistema não foi inicializado!");
				return false;
			}

			var sep = getSeparator();
			var chartPath = chartsPath + sep + chartName + ".json";
			
			if (FileSystem.exists(chartPath))
			{
				FileSystem.deleteFile(chartPath);
				trace("[ModManager] ✓ Chart deletado: " + chartName);
				return true;
			}
			
			return false;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao deletar chart: " + e);
			return false;
		}
		#else
		return false;
		#end
	}
	
	public static function createMod(modName:String, author:String, version:String = "1.0"):Bool
	{
		#if sys
		if (!initialized)
		{
			trace("[ModManager] Sistema não foi inicializado!");
			return false;
		}

		try
		{
			var sep = getSeparator();
			var modPath = modsPath + sep + modName;
			
			if (FileSystem.exists(modPath))
			{
				trace("[ModManager] ✗ Mod '" + modName + "' já existe!");
				return false;
			}
			
			FileSystem.createDirectory(modPath);
			FileSystem.createDirectory(modPath + sep + "charts");
			FileSystem.createDirectory(modPath + sep + "sounds");
			FileSystem.createDirectory(modPath + sep + "art");
			
			var modData:ModData = {
				name: modName,
				author: author,
				version: version,
				description: "Custom mod for Kade Engine",
				charts: [],
				enabled: true
			};
			
			var json = Json.stringify(modData, null, "  ");
			File.saveContent(modPath + sep + "mod.json", json);
			
			mods.set(modName, modData);
			trace("[ModManager] ✓ Mod criado: " + modName);
			return true;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao criar mod: " + e);
			return false;
		}
		#else
		return false;
		#end
	}
	
	public static function loadAllMods():Void
	{
		#if sys
		try
		{
			if (!FileSystem.exists(modsPath))
			{
				trace("[ModManager] Caminho não existe: " + modsPath);
				return;
			}
			
			var modFolders = FileSystem.readDirectory(modsPath);
			var sep = getSeparator();
			var count = 0;
			
			for (folder in modFolders)
			{
				var modPath = modsPath + sep + folder;
				
				if (FileSystem.isDirectory(modPath))
				{
					var modJsonPath = modPath + sep + "mod.json";
					
					if (FileSystem.exists(modJsonPath))
					{
						try
						{
							var json = File.getContent(modJsonPath);
							var modData:ModData = Json.parse(json);
							mods.set(folder, modData);
							trace("[ModManager] ✓ Mod carregado: " + folder);
							count++;
						}
						catch (e)
						{
							trace("[ModManager] Aviso ao carregar mod '" + folder + "': " + e);
						}
					}
				}
			}
			
			trace("[ModManager] Total de mods: " + count);
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao carregar mods: " + e);
		}
		#end
	}
	
	public static function saveChart(modName:String, chartName:String, chartData:ChartData):Bool
	{
		#if sys
		if (!initialized)
		{
			trace("[ModManager] Sistema não foi inicializado!");
			return false;
		}

		try
		{
			var sep = getSeparator();
			var modPath = modsPath + sep + modName;
			var chartsPathMod = modPath + sep + "charts";
			var chartPath = chartsPathMod + sep + chartName + ".json";
			
			if (!FileSystem.exists(modPath))
			{
				trace("[ModManager] ✗ Mod não existe: " + modName);
				return false;
			}
			
			if (!FileSystem.exists(chartsPathMod))
			{
				FileSystem.createDirectory(chartsPathMod);
			}
			
			var json = Json.stringify(chartData, null, "  ");
			File.saveContent(chartPath, json);
			
			if (mods.exists(modName))
			{
				var mod = mods.get(modName);
				if (!mod.charts.contains(chartName))
				{
					mod.charts.push(chartName);
					updateModJson(modName, mod);
				}
			}
			
			trace("[ModManager] ✓ Chart do mod salvo: " + chartName);
			return true;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao salvar chart: " + e);
			return false;
		}
		#else
		return false;
		#end
	}
	
	public static function loadChart(modName:String, chartName:String):ChartData
	{
		#if sys
		try
		{
			if (!initialized)
			{
				trace("[ModManager] Sistema não foi inicializado!");
				return null;
			}

			var sep = getSeparator();
			var chartPath = modsPath + sep + modName + sep + "charts" + sep + chartName + ".json";
			
			if (!FileSystem.exists(chartPath))
			{
				trace("[ModManager] ✗ Chart não encontrado: " + chartPath);
				return null;
			}
			
			var json = File.getContent(chartPath);
			var chartData:ChartData = Json.parse(json);
			trace("[ModManager] ✓ Chart do mod carregado: " + chartName);
			return chartData;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao carregar chart: " + e);
			return null;
		}
		#else
		return null;
		#end
	}
	
	public static function deleteChart(modName:String, chartName:String):Bool
	{
		#if sys
		try
		{
			if (!initialized)
			{
				trace("[ModManager] Sistema não foi inicializado!");
				return false;
			}

			var sep = getSeparator();
			var chartPath = modsPath + sep + modName + sep + "charts" + sep + chartName + ".json";
			
			if (FileSystem.exists(chartPath))
			{
				FileSystem.deleteFile(chartPath);
				
				if (mods.exists(modName))
				{
					var mod = mods.get(modName);
					mod.charts.remove(chartName);
					updateModJson(modName, mod);
				}
				
				trace("[ModManager] ✓ Chart do mod deletado: " + chartName);
				return true;
			}
			
			return false;
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao deletar chart: " + e);
			return false;
		}
		#else
		return false;
		#end
	}
	
	public static function listCharts(modName:String):Array<String>
	{
		if (mods.exists(modName))
		{
			return mods.get(modName).charts;
		}
		return [];
	}
	
	public static function listMods():Array<String>
	{
		var modList:Array<String> = [];
		for (key in mods.keys())
		{
			modList.push(key);
		}
		return modList;
	}
	
	private static function updateModJson(modName:String, modData:ModData):Void
	{
		#if sys
		try
		{
			var sep = getSeparator();
			var modPath = modsPath + sep + modName;
			var json = Json.stringify(modData, null, "  ");
			File.saveContent(modPath + sep + "mod.json", json);
			mods.set(modName, modData);
		}
		catch (e)
		{
			trace("[ModManager] ✗ Erro ao atualizar mod.json: " + e);
		}
		#end
	}
	
	public static function getModPath(modName:String):String
	{
		var sep = getSeparator();
		return modsPath + sep + modName;
	}
	
	public static function getChartsPath(modName:String):String
	{
		var sep = getSeparator();
		return modsPath + sep + modName + sep + "charts";
	}
	
	public static function getSoundsPath(modName:String):String
	{
		var sep = getSeparator();
		return modsPath + sep + modName + sep + "sounds";
	}
	
	public static function getArtPath(modName:String):String
	{
		var sep = getSeparator();
		return modsPath + sep + modName + sep + "art";
	}
	
	public static function getSavesDirectory():String
	{
		return savesPath;
	}
	
	public static function getChartsDirectory():String
	{
		return chartsPath;
	}
	
	public static function enableMod(modName:String):Bool
	{
		if (mods.exists(modName))
		{
			mods.get(modName).enabled = true;
			updateModJson(modName, mods.get(modName));
			return true;
		}
		return false;
	}
	
	public static function disableMod(modName:String):Bool
	{
		if (mods.exists(modName))
		{
			mods.get(modName).enabled = false;
			updateModJson(modName, mods.get(modName));
			return true;
		}
		return false;
	}
	
	public static function isMod(modName:String):Bool
	{
		return mods.exists(modName);
	}
	
	public static function getModData(modName:String):ModData
	{
		return mods.get(modName);
	}
}