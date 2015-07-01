@objc(CDAudioList)
public class CDAudioList: _CDAudioList {

	// Custom logic goes here.
    public func deleteAudio(audio: CDAudio) {
        if audio.lists.containsObject(self) {
            self.removeAudiosObject(audio)
            if audio.lists.count == 0 {
                self.managedObjectContext?.deleteObject(audio)
            }
        }
    }
    
}
