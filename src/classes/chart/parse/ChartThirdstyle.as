package classes.chart.parse {
	
	import classes.chart.*;
	import com.flashfla.utils.*;
	
	public class ChartThirdstyle extends NoteChart {
		
		public function ChartThirdstyle(id:Number, inData:String, framerate:int = 60):void {
			type = NoteChart.THIRDSTYLE;
			super(id, JSON.parse(inData), framerate);
			
			//- Set Gap
			this.gap = Number(chartData["timingData"]["offsetStr"]);
			
			//- Set BPM's
			BPMs.push(new BPMSegment(0.0, Number(chartData["timingData"]["bpmsStr"].split(",")[0].split("=")[1])));
			addBPMs(chartData["timingData"]["bpmsStr"]);
			
			//- Set Freeze's
			addFreezes(chartData["timingData"]["stopsStr"]);
			
			//- Set Notes
			var noteSplit:Array = chartData["noteData"].split(",");
			
			for (var i:int = 0; i < noteSplit.length; i++) {
				extractNotesFromLine(noteSplit[i], noteSplit[i].length / 4, i);
			}
			
			//- Set Note Frames
			notesToFrame();
		}
		
		private function extractNotesFromLine(s:String, divisor:int, measure:int):void {
			for (var i:int = 0; i < divisor; i++) {
				// Set Color
				
				var col:String;
				if (i == 0 || reduce(i, divisor) == 2 || reduce(i, divisor) == 4) {
					col = "red";
				} else if (reduce(i, divisor) == 8) {
					col = "blue";
				} else if (reduce(i, divisor) == 3 || reduce(i, divisor) == 6 || reduce(i, divisor) == 12) {
					col = "purple";
				} else if (reduce(i, divisor) == 16) {
					col = "yellow";
				} else if (reduce(i, divisor) == 24) {
					col = "pink";
				} else if (reduce(i, divisor) == 32) {
					col = "orange";
				} else if (reduce(i, divisor) == 48) {
					col = "cyan";
				} else if (reduce(i, divisor) == 64) {
					col = "green";
				} else {
					col = "white";
				}
				
				// Get 4 Char Chunk
				var chunk:String = s.substr(i * 4, 4);
				
				// Add Notes
				if (chunk.charAt(0) == "1" || chunk.charAt(0) == "2")
					Notes.push(new Note("L", measure + i / divisor, col));
				if (chunk.charAt(1) == "1" || chunk.charAt(1) == "2")
					Notes.push(new Note("D", measure + i / divisor, col));
				if (chunk.charAt(2) == "1" || chunk.charAt(2) == "2")
					Notes.push(new Note("U", measure + i / divisor, col));
				if (chunk.charAt(3) == "1" || chunk.charAt(3) == "2")
					Notes.push(new Note("R", measure + i / divisor, col));
			}
		}
		
		public function reduce(num:int, denom:int):int {
			return denom / ExtraMath.getGCD(num, denom);
		}
		
		public function addBPMs(s:String):void {
			if (s.indexOf(",") >= 0) {
				addBPMs(s.substring(0, s.indexOf(",")));
				addBPMs(s.substring(s.indexOf(",") + 1));
			} else {
				var start:Number = Number(s.substring(0, s.indexOf("=")));
				var bpm:Number = Number(s.substring(s.indexOf("=") + 1));
				if (BPMs.length != 0) {
					BPMs[BPMs.length - 1].setEnd(start / 16);
				}
				BPMs.push(new BPMSegment(start / 16, bpm));
			}
		}
		
		public function addFreezes(s:String):void {
			if (s.indexOf(",") >= 0) {
				addFreezes(s.substring(0, s.indexOf(",")));
				addFreezes(s.substring(s.indexOf(",") + 1));
			} else {
				var pos:Number = Number(s.substring(0, s.indexOf("=")));
				var length:Number = Number(s.substring(s.indexOf("=") + 1));
				Stops.push(new Stop(pos / 16, length / 1000));
			}
		}
	
	}

}