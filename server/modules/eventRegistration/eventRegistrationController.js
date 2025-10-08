import EventRegistration from './eventRegistrationModel.js';
import AppError from '../../utils/appError.js';
import Event from '../event/eventModel.js';
import catchAsync from '../../utils/catchAsync.js';

// This controller will handle both registering and un-registering (toggling)
export const toggleRsvp = catchAsync(async (req, res, next) => {
console.log("--- RSVP ENDPOINT TRIGGERED ---");
  const { eventId } = req.params;
  const userId = req.user.id; // Comes from your isAuthenticated middleware


const event = await Event.findById(eventId);
  if (!event) {
  console.error(`❌ Event not found with ID: ${eventId}`);
    return res.status(404).json({ status: 'error', message: 'Event not found' });
  }

  console.log(`1. Found event. Current RSVP array: [${event.rsvp.join(', ')}]`);

  // 2. Check if the user's ID is already in the 'rsvp' array
  const isRsvpd = event.rsvp.map(id => id.toString()).includes(userId);
  console.log(`2. Is user already RSVP'd? ${isRsvpd}`);

  if (isRsvpd) {
    // 3a. If user is in the array, remove them (un-RSVP)
    await Event.findByIdAndUpdate(eventId, { $pull: { rsvp: userId } });

    console.log(`User ${userId} UN-REGISTERED from event ${eventId}`);
    res.status(200).json({ status: 'success', message: 'Successfully unregistered',data: { rsvpd: false } });
  } else {
    // 3b. If user is not in the array, add them (RSVP)
    await Event.findByIdAndUpdate(eventId, { $addToSet: { rsvp: userId } }); // $addToSet prevents duplicates

    console.log(`User ${userId} REGISTERED for event ${eventId}`);
    res.status(200).json({ status: 'success', message: 'Successfully registered',data: { rsvpd: true } });
  }
});

        const updatedEvent = await Event.findByIdAndUpdate(eventId, updateOperation, { new: true });


        console.log(` Event AFTER update. New RSVP array: [${updatedEvent.rsvp.join(', ')}]`);

        res.status(200).json(responseMessage);

      } catch (error) {
        console.error("--- ❌ CATASTROPHIC ERROR IN RSVP CONTROLLER ---", error);
        res.status(500).json({ status: 'error', message: 'Internal Server Error' });
      }
    });

// This controller now finds the event and populates the 'rsvp' array
export const getRegistrationsForEvent = catchAsync(async (req, res, next) => {
    const event = await Event.findById(req.params.eventId).populate('rsvp');

    if (!event) {
      return res.status(404).json({ status: 'error', message: 'Event not found' });
    }

    res.status(200).json({
        status: 'success',
        results: event.rsvp.length,
        data: {
            registrations: event.rsvp // The populated list of users
        }
    });
});
//  // Check if a registration already exists
//  const existingRegistration = await EventRegistration.findOne({
//    event: eventId,
//    user: userId,
//  });
//
//  if (existingRegistration) {
//    // If it exists, user wants to un-RSVP. So, delete it.
//    await EventRegistration.findByIdAndDelete(existingRegistration._id);
//
//    res.status(200).json({
//      status: 'success',
//      message: 'Successfully unregistered from the event.',
//      data: {
//        rsvpd: false,
//      }
//    });
//  } else {
//    // If it doesn't exist, user wants to RSVP. So, create it.
//    const newRegistration = await EventRegistration.create({
//      event: eventId,
//      user: userId,
//    });
//
//    res.status(201).json({
//      status: 'success',
//      message: 'Successfully registered for the event!',
//      data: {
//        registration: newRegistration,
//        rsvpd: true,
//      }
//    });
//  }
//});
//
//// A controller to get all users for an event (for organizers)
//export const getRegistrationsForEvent = catchAsync(async (req, res, next) => {
//    const registrations = await EventRegistration.find({ event: req.params.eventId }).populate('user');
//    res.status(200).json({
//        status: 'success',
//        results: registrations.length,
//        data: {
//            registrations
//        }
//    });
//});

