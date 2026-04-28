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
			// Detecta a plataforma e define o caminho correto
			#if android
				modsPath = "/storage/emulated/0/.Kadesh/mods";
			#elseif ios
				// iOS usa Document directory
				modsPath = lime.system.System.documentsDirectory + ".Kadesh/mods";
			#elseif sys
				// Desktop - cria relativo ao diretório de execução
				modsPath = Sys.getCwd() + ".Kadesh" + java.nio.file.FileSystems.getDefault().getSeparator() + "mods";
			#else
				modsPath = ".Kadesh/mods";
			#end
			
			trace("[ModManager] Caminho dos mods: " + modsPath);
			
			createModDirectories();
			loadAllMods();
			
			initialized = true;
			trace("[ModManager] ✓ Sistema de mods inicializado com sucesso!");
		}
		catch (e)
		{
			trace("[ModManager] ✗ ERRO CRÍTICO ao inicializar: " + e);
			// Não mata o jogo, apenas registra o erro
			initialized = false;
		}
	}
	
	private static function createModDirectories():Void
	{
		#if sys
		try
		{
			// Cria pasta raiz .Kadesh/mods
			if (!FileSystem.exists(modsPath))
			{
				trace("[ModManager] Criando diretório: " + modsPath);
				createDirectoryRecursive(modsPath);
				trace("[ModManager] ✓ Diretório de mods criado!");
			}
			else
			{
				trace("[ModManager] Diretório de mods já existe.");
			}
			
			// Cria subpastas padrão
			var chartsPath = modsPath + java.nio.file.FileSystems.getDefault().getSeparator() + "charts";
			var soundsPath = modsPath + java.nio.file.FileSystems.getDefault().getSeparator() + "sounds";
			var artPath = modsPath + java.nio.file.FileSystems.getDefault().getSeparator() + "art";
			
			createIfNotExists(chartsPath);
			createIfNotExists(soundsPath);
			createIfNotExists(artPath);
			
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
		var dirs = path.split(java.nio.file.FileSystems.getDefault().getSeparator());
		var currentPath = "";
		
		for (dir in dirs)
		{
			if (dir == "")
				continue;
			
			currentPath += dir + java.nio.file.FileSystems.getDefault().getSeparator();
			
			if (!FileSystem.exists(currentPath))
			{
				try
				{
					FileSystem.createDirectory(currentPath);
				}
				catch (e)
				{
					trace("[ModManager] Aviso: Não foi possível criar " + currentPath + " - " + e);
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
			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
			var modPath = modsPath + sep + modName;
			
			if (FileSystem.exists(modPath))
			{
				trace("[ModManager] ✗ Mod '" + modName + "' já existe!");
				return false;
			}
			
			// Cria estrutura da pasta do mod
			FileSystem.createDirectory(modPath);
			FileSystem.createDirectory(modPath + sep + "charts");
			FileSystem.createDirectory(modPath + sep + "sounds");
			FileSystem.createDirectory(modPath + sep + "art");
			
			// Cria mod.json
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
			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
			
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
						}
						catch (e)
						{
							trace("[ModManager] Aviso ao carregar mod '" + folder + "': " + e);
						}
					}
				}
			}
			
			trace("[ModManager] Total de mods: " + mods.size());
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
			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
			var modPath = modsPath + sep + modName;
			var chartsPath = modPath + sep + "charts";
			var chartPath = chartsPath + sep + chartName + ".json";
			
			if (!FileSystem.exists(modPath))
			{
				trace("[ModManager] ✗ Mod não existe: " + modName);
				return false;
			}
			
			if (!FileSystem.exists(chartsPath))
			{
				FileSystem.createDirectory(chartsPath);
			}
			
			var json = Json.stringify(chartData, null, "  ");
			File.saveContent(chartPath, json);
			
			// Atualiza a lista de charts no mod.json
			if (mods.exists(modName))
			{
				var mod = mods.get(modName);
				if (!mod.charts.contains(chartName))
				{
					mod.charts.push(chartName);
					updateModJson(modName, mod);
				}
			}
			
			trace("[ModManager] ✓ Chart salvo: " + chartName);
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

			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
			var chartPath = modsPath + sep + modName + sep + "charts" + sep + chartName + ".json";
			
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

			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
			var chartPath = modsPath + sep + modName + sep + "charts" + sep + chartName + ".json";
			
			if (FileSystem.exists(chartPath))
			{
				FileSystem.deleteFile(chartPath);
				
				// Remove da lista do mod.json
				if (mods.exists(modName))
				{
					var mod = mods.get(modName);
					mod.charts.remove(chartName);
					updateModJson(modName, mod);
				}
				
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
			var sep = java.nio.file.FileSystems.getDefault().getSeparator();
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
		var sep = java.nio.file.FileSystems.getDefault().getSeparator();
		return modsPath + sep + modName;
	}
	
	public static function getChartsPath(modName:String):String
	{
		var sep = java.nio.file.FileSystems.getDefault().getSeparator();
		return modsPath + sep + modName + sep + "charts";
	}
	
	public static function getSoundsPath(modName:String):String
	{
		var sep = java.nio.file.FileSystems.getDefault().getSeparator();
		return modsPath + sep + modName + sep + "sounds";
	}
	
	public static function getArtPath(modName:String):String
	{
		var sep = java.nio.file.FileSystems.getDefault().getSeparator();
		return modsPath + sep + modName + sep + "art";
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
