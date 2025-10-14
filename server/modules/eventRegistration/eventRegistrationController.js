import EventRegistration from './eventRegistrationModel.js';
import AppError from '../../utils/appError.js';
import Event from '../event/eventModel.js';
import catchAsync from '../../utils/catchAsync.js';

// This controller will handle both registering and un-registering (toggling)
export const toggleRsvp = catchAsync(async (req, res, next) => {
//console.log("--- RSVP ENDPOINT TRIGGERED ---");
  const { eventId } = req.params;
  const userId = req.user.id; // Comes from your isAuthenticated middleware


const event = await Event.findById(eventId);
  if (!event) {
  console.error(`❌ Event not found with ID: ${eventId}`);
    return res.status(404).json({ status: 'error', message: 'Event not found' });
  }
  const currentRsvp = Array.isArray(event.rsvp) ? event.rsvp : [];

  //console.log(`1. Found event. Current RSVP array: [${currentRsvp.join(', ')}]`);

  // 2. Check if the user's ID is already in the 'rsvp' array
  const isRsvpd = currentRsvp.map(id => id.toString()).includes(userId);
  //console.log(`2. Is user already RSVP'd? ${isRsvpd}`);

  const updateOperation = isRsvpd
      ? { $pull: { rsvp: userId } }            // remove
      : { $addToSet: { rsvp: userId } };      // add without duplicates

    const responseMessage = isRsvpd
      ? { status: 'success', message: 'Successfully unregistered', data: { rsvpd: false } }
      : { status: 'success', message: 'Successfully registered',   data: { rsvpd: true } };

    // 4) apply update and return updated document
    const updatedEvent = await Event.findByIdAndUpdate(eventId, updateOperation, { new: true });

    if (!updatedEvent) {
      // extremely unlikely since we found it earlier, but safe to check
      //console.error(`❌ Event disappeared during update: ${eventId}`);
      return res.status(404).json({ status: 'error', message: 'Event not found after update' });
    }

    //console.log(`Event AFTER update. New RSVP array: [${(updatedEvent.rsvp || []).join(', ')}]`);

    return res.status(200).json(responseMessage);
  });


  export const getRegistrationsForEvent = catchAsync(async (req, res, next) => {
    // populate rsvp to return user documents (optionally select fields)
    const event = await Event.findById(req.params.eventId).populate('rsvp', 'name email'); // adjust selected fields as needed

    if (!event) {
      return res.status(404).json({ status: 'error', message: 'Event not found' });
    }

    res.status(200).json({
      status: 'success',
      results: Array.isArray(event.rsvp) ? event.rsvp.length : 0,
      data: {
        registrations: event.rsvp
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

