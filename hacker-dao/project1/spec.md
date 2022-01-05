# Project spec
- The smart contract is reusable; multiple projects can be registered and accept ETH concurrently.
- The goal is a preset amount of ETH.
  - This cannot be changed after a project gets created.
- Regarding contributing:
  - The contribute amount must be at least 0.01 ETH.
  - There is no upper limit.
  - Anyone can contribute to the project, including the creator.
  - One address can contribute as many times as they like.
- If the project is not fully funded within 30 days:
  - The project goal is considered to have failed
  - No one can contribute anymore
  - Supporters get their money back
- If the project is fully funded:
  - No one else can contribute (however, the last contribution can go over the goal)
  - The creator can withdraw any percentage of contributed funds
- The creator can choose to cancel their project before the 30 days are over

## additional questions answered from "the client"

- What kind of information do we need to collect from creators during the project registration process (eg, what does a “project” consist of)?
  - amt of Eth for the goal
- How do users contribute to a project? (What does the interface look like?)
  - No UI
- Specific denominations?
Only ETH
- Is there a minimum or limit to the amount that can be donated?
  - Must be at least 0.01 ETH
- Once the goal has been met, what happens?
  - Creators can withdraw the contributed funds
- Can the project keep accruing donations?
  - After a goal is met, no one else can contribute
- Do users get anything back from the project (how are they incentivized to contribute)?
  - No, incentive is just to fund cool projects
- Is there a time limit to taking donations?
  - 30 days after project create
- What happens if that’s reached and the goal has not been met?
  - Contributors get their money back
- What measures exist to prevent hackers from withdrawing the funds?
  - Not sure (as a client)
