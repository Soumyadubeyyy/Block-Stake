import React, { useEffect, useState } from 'react';
import './App.css';
import Wallet from './components/Wallet/Wallet';
import Navigation from './components/Navigation/Navigation';
import Display from './components/DisplayInfo/Display';
import TokenApproval from './components/Stake/TokenApproval';
import StakeAmount from './components/Stake/StakeAmount';
import Withdraw from './components/Withdrawal/Withdraw';
import { StakingProvider } from './components/Context/StakingContext';
import FutureUseAnimations from './components/Animation/FutureUseAnimations ';

function App() {
  const [displaySection, setDisplaySection] = useState("stake");
  const [isDarkMode, setIsDarkMode] = useState(false);


  const handleButtonClick = (section) => {
    setDisplaySection(section);
  };

  const toggleTheme = () => {
    setIsDarkMode(!isDarkMode);
  };

  useEffect(() => {
    if (isDarkMode) {
      document.body.classList.add('dark');
    } else {
      document.body.classList.remove('dark');
    }
  }, [isDarkMode]);

  return (
    
      <div className="main-section">
        <Wallet>
          <Navigation isDarkMode={isDarkMode} toggleTheme={toggleTheme} />
          <StakingProvider>
            <div className="content-wrapper">
            <div class="side-section2">
        <h2>BlockStake Hub: Revolutionizing Crypto Staking</h2>
        <ul>
            <li>Explore BlockStake Hub, an innovative DeFi platform crafted to optimize your staking returns effortlessly.</li>
            <li>Rest assured with BlockStake Hub’s secure, audited smart contracts ensuring utmost transparency and security.</li>
            <li>Enjoy the flexibility of staking a diverse array of cryptocurrencies tailored to meet your investment objectives.</li>
            
        </ul>
    </div>
              <div className="main-content">
                <Display />
                <div className="button-section">
                  <button
                    onClick={() => handleButtonClick("stake")}
                    className={displaySection === "stake" ? "" : "active"}
                  >
                    Stake
                  </button>
                  <button
                    onClick={() => handleButtonClick("withdraw")}
                    className={displaySection === "withdraw" ? "" : "active"}
                  >
                    Withdraw
                  </button>
                </div>
                {displaySection === "stake" && (
                  <div className="stake-wrapper">
                    <TokenApproval />
                    <StakeAmount/>
                  </div>
                )}
                {displaySection === "withdraw" && (
                  <div className="stake-wrapper">
                    <Withdraw />
                  </div>
                )}
              </div>
              <div className="side-section">
                <div className="future-use">
                <FutureUseAnimations />
                </div>
              </div>
            </div>
          </StakingProvider>
        </Wallet>
      </div>
    
  );
}

export default App;
