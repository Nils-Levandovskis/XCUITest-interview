import Foundation
import AmazonIVSPlayer

class PlayerController: NSObject {
    private let player = IVSPlayer()
    static var url = URL(string: "https://4c62a87c1810.us-west-2.playback.live-video.net/api/video/v1/us-west-2.049054135175.channel.GHRwjPylmdXm.m3u8")!
    
    public var didOutputCueHook: ((IVSCue) -> Void)? = nil
    public var didChangeStateHook: ((IVSPlayer.State) -> Void)? = nil
    public var didChangeDurationHook: ((CMTime) -> Void)? = nil
    public var didSeekToHook: ((CMTime) -> Void)? = nil

    override init() {
        super.init()
        self.setupPlayer()
    }
    
    func loadStream() {
        player.load(PlayerController.url)
    }
    
    func setupPlayer() {
        player.delegate = self
    }
}

extension PlayerController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        didChangeStateHook?(state)
    }
    
    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        didChangeDurationHook?(duration)
    }
    
    func player(_ player: IVSPlayer, didSeekTo time: CMTime) {
        didSeekToHook?(time)
    }

    func player(_ player: IVSPlayer, didOutputCue cue: IVSCue) {
        didOutputCueHook?(cue)
    }
}
