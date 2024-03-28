/**
 * @file uwmulti-traffic-rl.h
 * @author Michele Scapinello
 * @version 1.0.0
*/


#ifndef UWMULTI_TRAFFIC_RL_H
#define UWMULTI_TRAFFIC_RL_H

#include "uwmulti-traffic-control.h"

class UwMultiTrafficRl : public UwMultiTrafficControl {

    public:
        /**
         * Constructor of UwMultiTrafficRl class.
        */
        UwMultiTrafficRl();

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
        virtual int command(int, const char*const*);

        /** 
         * Handle a packet coming from upper layers
         * 
         * @param p pointer to the packet
         */
        virtual void recv(Packet* p, int idSrc);

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
        virtual int getBestLowerLayer(int traffic, Packet *p = NULL);

        /**
         * Retrieves the current statistics of the corresponding module id, used afterwards
         * in the RL algorithm to select the best transmission medium.
         * 
         * @param module_id physical layer module id
        */
        virtual void getCurrentStatistics(int module_id);

    private:
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
                 * Destructor of UwReinforcementTimer
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
};

#endif /* UWMULTI_TRAFFIC_RL_H */