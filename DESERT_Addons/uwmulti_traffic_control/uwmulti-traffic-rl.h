/**
 * @file uwmulti-traffic-rl.h
 * @author Michele Scapinello
 * @version 1.0.0
*/


#ifndef UWMULTI_TRAFFIC_RL_H
#define UWMULTI_TRAFFIC_RL_H

#include "uwmulti-traffic-control.h"

class RlAgent {
    private:
        /*
        * features -> map to contain the features for the RL agent
        * weigths -> vector containing the value of the weights for a specific instance
        */
        std::map<std::string, float> features;
        std::vector<float> weights;
        
    public:
        /**
         * Constructor of the RlAlgorithm class
        */
        RlAgent(): features(), weights() {};

        /**
         * Destructor of the RlAlgorithm class
        */
        ~RlAgent() {};

        /**
         * Function to update the weights of the RlAlgorithm
         * 
         * @param rewards array of rewards collected during communications
         * @param reward instantaneous reward of a single pakcet
         * 
         * TODO -> Decide wether to use istantaneous reward or delayed
         * 
        */
        void updateWeights(std::array<float, 10> rewards);

        /**
         * Function to compute the reward based on the condition of the received packet
         * 
         * @param p packet received during communication
        */
        float getInstantaneousReward(Packet* p);

        /**
         * Retrieves the current statistics of the corresponding module id, used afterwards
         * in the RL algorithm to select the best transmission medium.
         * 
         * @param module_id physical layer module id
        */
        virtual void updateSourceNodeStats();

        /**
         * Retrieves the current statistics of the corresponding module id, used afterwards
         * in the RL algorithm to select the best transmission medium.
        */
        virtual void updateDestinationNodeStats();        
};
        

class UwMultiTrafficRl : public UwMultiTrafficControl {

    public:
        /**
         * Constructor of UwMultiTrafficRl class.
        */
        UwMultiTrafficRl() : phy_IDs() {};

        /**
         * Destructor of UwMultiTrafficRl class.
        */
        virtual ~UwMultiTrafficRl() { }

        /**
         * TCL command interpreter. It implements the following OTcl methods:
         *
         * @param argc Number of arguments in <i>argv</i>.
         * @param argv Array of strings which are the command parameters (Note that <i>argv[0]</i> 
         *             is the name of the object).
         *
         * @return TCL_OK or TCL_ERROR whether the command has been dispatched successfully or not.
         */
        virtual int command(int argc, const char*const* argv);

        /** 
         * Handle a packet coming from upper layers
         * 
         * @param p pointer to the packet
         */
        virtual void recv(Packet* p);

        /** 
         * Discover the underlying PHY layers
         */
        virtual void discoverLowerLayers();

        virtual int recvSyncClMsg(ClMessage* msg);

    protected:
        /** 
         * manage to tx a packet of traffic type
         *
         * @param traffic application traffic id
         */
        virtual void manageBuffer(int traffic);

        /** 
         * Return the Best Lower Layer id where to forward the packet of <i>traffic</i> type.
         * The algorithm implemented is a linear version of the Q-learning algorithm
         * 
         * @param traffic application traffic id
         *
         * @return the layer id
         */
        virtual int getBestLowerLayer(Packet *p = NULL);

    private:
        RlAgent q_learning;

        std::vector<int> phy_IDs; // Structure to store the physical modules id of the node
        int best_phy_layer; // best physical module id computed according to the algorithm
        std::map<int, int> macTclIdLayerId;
       /**
        * Function to initialize the layer at beginning.
        * Perform a discovery of the connected physical layer and stores them in a data
       */
        void initialize();

        /**
         * Definition of timer class. When it expires, the RL algorithm updates the selected medium
         * for the transmission of the packets
        */
       class UwCheckMediumTimer : public TimerHandler {
            
            public:
                /**
                 * Constructor of the UwCheckRangeTimer class.
                */
                UwCheckMediumTimer(UwMultiTrafficRl *m);
                /**
                 * Destructor of UwCheckRangeTimer
                */
                ~UwCheckMediumTimer() {}

            protected:
                /**
                 * Timer expire procedure: handles the medium selecton timeout
                 * @param Event *e, pointer to the event that cause the expire
                 */
                virtual void expire(Event *e);
                /*
                 * Pointer to the module class where the timer is used
                */
                UwMultiTrafficRl* module; 
       };

        /**
        * Definition of timer class. When it expires it triggers the RX to send a packet
        * containing information abour the rewards collected during the exchange of information
        */
       class UwGetRewardTimer : public TimerHandler {
            
            public:
                /**
                 * Constructor of the UwGetRewardTimer class.
                */
                UwGetRewardTimer(UwMultiTrafficRl *m);
                /**
                 * Destructor of UwGetRewardTimer
                */
                ~UwGetRewardTimer() {}

            protected:
                /**
                 * Timer expire procedure: handles the medium selecton timeout
                 * @param Event *e, pointer to the event that cause the expire
                 */
                virtual void expire(Event *e);
                /*
                 * Pointer to the module class where the timer is used
                */
                UwMultiTrafficRl* module; 
       };
};

#endif /* UWMULTI_TRAFFIC_RL_H */