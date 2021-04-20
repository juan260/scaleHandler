class ScaleHandler{
    
    127 => int maxScaleTableSize;
    50 => int maxScales;
    float scaleTables[0][maxScaleTableSize];
    string knownScales[maxScales];
    0 => int currentKnownScales;
    
    string currentScale;
    int currentTranspose;
    4 => int roundNoteWeight;
    
    initScaleTable() @=> scaleTables; 

    
    fun int changeScale(string newScale){
        for(0=>int i;i<currentKnownScales;i++){
            if(knownScales[i]==newScale){
                newScale => currentScale;
                <<< "Scale Changed", newScale >>>;
                return 1;
            }
        }
        return -1;
    }
    
    fun int inSilence(){
        return currentScale == "Silence";
    }
            
    fun float specialRound(float startingPoint, float target, int weight, float distance){
        //<<< "Special", startingPoint, target, distance, Math.pow(2*(startingPoint-target)/distance, 2*weight+1)*distance/2 + target>>>;
        return Math.pow(2*(startingPoint-target)/distance, 2*weight+1)*distance/2 + target;
        //return startingPoint;
    }    


    fun float getRoundedMidi(float midiNote){
        
        midiNote => float original;
        Math.max(0, midiNote) => midiNote; 
        Math.min(maxScaleTableSize-2, midiNote) => midiNote;
        Math.round(midiNote) => float midiNoteIndex;
        scaleTables[currentScale][(midiNoteIndex $ int)]+currentTranspose => midiNote;
        
        1.0 => float distance;
        midiNote => float startingPoint;
        original-Math.floor(original) => float decimalPart;
        //<<<original, midiNote, decimalPart>>>;
         
        if(original > Math.round(original)){
            scaleTables[currentScale][(midiNoteIndex $ int)+1]-midiNote => distance; 
            midiNote + decimalPart*distance => startingPoint;
            <<< "Ord1", midiNote, 
            scaleTables[currentScale][(midiNoteIndex $ int)+1], 
            decimalPart, distance, startingPoint, specialRound(startingPoint, midiNote, roundNoteWeight, distance)>>>;
        }
        else {
            midiNote-scaleTables[currentScale][(midiNoteIndex $ int)-1] => distance;    
            midiNote - (1-decimalPart)*distance => startingPoint;
            <<< "Ord2", scaleTables[currentScale][(midiNote $ int)-1], 
            midiNote, 
            decimalPart, distance, startingPoint, specialRound(startingPoint, midiNote, roundNoteWeight, distance)>>>;
       
        }
        return specialRound(startingPoint, midiNote, roundNoteWeight, distance);
    }

       

    fun float getRoundedFreq(float freq){
                
                Std.ftom(freq) => float midiNote;
                return getRoundedFreqFromMidi(midiNote);
            }
            
    fun float getRoundedFreqFromMidi(float midiNote){
        
        return Std.mtof(getRoundedMidi(midiNote));
    }
            
    fun int recalculateTransposition(float freq){
            return 0; //TODO
        }

    fun int positiveModulo(int a, int m){
        return (a%m+m)%m;
    }

    fun float[] genScaleTable(float scale[], int maxScaleTableSize) {
        float scaleTable[maxScaleTableSize];
        int startingMidiNote;
        float currentMidiNote;
        int i;
        60 => startingMidiNote;
        60 => i;
        startingMidiNote => currentMidiNote;
        currentMidiNote => scaleTable[i];
        // Rellenamos la tabla hacia arriba
        while(i<maxScaleTableSize-1){
            i++; 
            scale[positiveModulo((i-startingMidiNote-1),scale.cap())] +=> currentMidiNote;
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote>126)
                break;
            
        }
        // Terminamos de rellenar hacia arriba
        while(i<maxScaleTableSize-1){
            i++;
            126 => scaleTable[i];
        }
        // Rellenamos la tabla hacia abajo
        startingMidiNote => i;
        startingMidiNote => currentMidiNote;
        while(i>0){
            i--;
            scale[positiveModulo((i-startingMidiNote),scale.cap())] -=> currentMidiNote;
            
            currentMidiNote => scaleTable[i];
            
            if(currentMidiNote<0)
                break;
            
        }
        // Terminamos de rellenar hacia abajo
        while(i>0){
            i--;
            0 => scaleTable[i];
        }
        return scaleTable;
        
        
        }
        
    fun float[][] addScaleToTable(string scaleName, float scale[]){
        <<< "Adding scale", scaleName>>>;
        genScaleTable(scale, maxScaleTableSize) @=> scaleTables[scaleName];
        scaleName => knownScales[currentKnownScales];
        if(currentKnownScales<maxScales-1)
            currentKnownScales++;
        return scaleTables;
    }

    fun float[][] initScaleTable() {
        float auxiliarTable[maxScaleTableSize];
        for (0 => int i; i<maxScaleTableSize; i++){
            -10000000 => auxiliarTable[i];
        }
        auxiliarTable @=> scaleTables["Silence"];
        "Silence" => currentScale;
        0 => currentTranspose;
        
        currentScale => knownScales[currentKnownScales];
        currentKnownScales++;

        return scaleTables;
    }   
}
