import UIKit

open class ViewController<AActionType: Action>: UIViewController, Subscribing {
    public typealias ActionType = AActionType
    
    public let store: Store<ActionType>

    // MARK: - Init
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(store: Store<ActionType>) {
        self.store = store

        super.init(nibName: nil, bundle: nil)

        subscribe(to: self.store)
    }

    // MARK: - Lifecycle
    
    deinit {
#if DEBUG
        print("[\(self)] --- DEINIT ---")
#endif
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dispatch(action: .lifeCycle(.didShowView))
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true

        dispatch(action: .lifeCycle(.didLoadView))
    }

    /// Method called when a state update has occurred
    open func stateDidUpdate(source: ActionEnvelop<ActionType>?,
                             oldState: Store<ActionType>.StateType?,
                             newState: Store<ActionType>.StateType,
                             completion: @escaping () -> ()) {
        fatalError("stateDidUpdate(source:oldState:newState:completion:) has not been implemented")
    }

    /// Registered name for the script
    ///
    /// ## Important Note ##
    /// - Should be overridden if two instances of the same stage are subscribing
    open var subscriptionName: String {
        return String(describing: type(of: self))
    }

    // MARK: Dispatch

    /// Dispatches an action to the store
    ///
    /// - Parameters:
    ///    - action: the action to be dispatched
    ///    - silent: if true, the `didStartLoading(silent:)` and `didFinishLoading(state:silent:)` will be called with
    ///              the parameter `silent` set to `true`
    ///    - debugInfo: a tuple containing the file, function and line from where the action has been dispatched
    open func dispatch(action: CoreAction<ActionType>,
                       silent: Bool? = nil,
                       debugInfo: ActionEnvelop<ActionType>.DebugInfo = (file: #file, function: #function, line: #line)) {
        let resolvedSilent = silent ?? isActionSilent(action)
        didStartLoading(silent: resolvedSilent)
        store.dispatch(ActionEnvelop(
                emitter: subscriptionName,
                action: action,
                payload: ["silent": resolvedSilent],
                debugInfo: debugInfo))
    }

    // MARK: - Loading

    public func didFinishStateUpdate(source: ActionEnvelop<ActionType>?,
                                     oldState: Store<ActionType>.StateType?,
                                     newState: Store<ActionType>.StateType) {
        let silent: Bool = {
            guard let sourceAction = source,
                  let payload = sourceAction.payload,
                  sourceAction.emitter == subscriptionName else {
                return true
            }

            guard let value = payload["silent"] as? Bool else {
                return true
            }

            return value
        }()

        didFinishLoading(state: newState, silent: silent)
    }

    /// Method called to know if an action should be dispatched silently or not.
    ///
    /// ## Important Note ##
    /// Should be overridden for custom behaviors
    open func isActionSilent(_ action: CoreAction<ActionType>) -> Bool {
        return true
    }

    /// Method called when the stage starts loading.
    ///
    /// ## Important Note ##
    /// Should be overridden for custom behaviors
    open func didStartLoading(silent: Bool) {
    }

    /// Method called when the stage finished loading.
    ///
    /// ## Important Note ##
    /// Should be overridden for custom behaviors
    open func didFinishLoading(state: Store<ActionType>.StateType, silent: Bool) {
    }
}