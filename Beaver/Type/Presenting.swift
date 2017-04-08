public protocol Presenting: Subscribing {
    var context: Context { get }
}

extension Presenting {
    /// Dispatches an action to the store and automatically sets the emitter to the scene's subscription nameScript<ActionType>
    public func dispatch(_ action: ActionType,
                         on store: Store<ActionType>,
                         payload: [AnyHashable: Any]? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {
        store.dispatch(ActionEnvelop(emitter: subscriptionName,
                                     action: action,
                                     payload: payload,
                                     file: file,
                                     function: function,
                                     line: line))
    }
}
